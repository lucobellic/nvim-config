---@class NotesBookmarks
---@field private config NotesConfig Reference to plugin configuration
local M = {}

--- Initialize bookmarks module with config reference
---@param config NotesConfig
function M.init(config) M.config = config end

--- Get the bookmark directory from config
---@return string bookmark_dir
function M.get_bookmark_dir() return M.config.bookmark_dir end

--- Get the full path for a bookmark file
---@param name string Bookmark name (without extension)
---@return string path Full path to the bookmark JSON file
function M.get_bookmark_path(name) return M.get_bookmark_dir() .. '/' .. name .. '.json' end

--- Ensure the bookmark directory exists
---@return boolean success
function M.ensure_dir()
  local dir = M.get_bookmark_dir()
  if vim.fn.isdirectory(dir) == 0 then
    local ok = vim.fn.mkdir(dir, 'p')
    if ok == 0 then
      vim.notify('Failed to create bookmark directory: ' .. dir, vim.log.levels.ERROR, { title = 'Notes' })
      return false
    end
  end
  return true
end

--- Save notes data to a bookmark file as JSON
---@param bookmark_path string Full path to the bookmark JSON file
---@param data BookmarkData Notes data to save
---@return boolean success
function M.save(bookmark_path, data)
  if not M.ensure_dir() then
    return false
  end

  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    vim.notify('Failed to encode notes data: ' .. tostring(encoded), vim.log.levels.ERROR, { title = 'Notes' })
    return false
  end

  local file, err = io.open(bookmark_path, 'w')
  if not file then
    vim.notify('Failed to write bookmark file: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Notes' })
    return false
  end

  file:write(encoded)
  file:close()
  return true
end

--- Load notes data from a bookmark file
---@param bookmark_path string Full path to the bookmark JSON file
---@return BookmarkData? data The loaded notes data, or nil on error
function M.load(bookmark_path)
  if vim.fn.filereadable(bookmark_path) == 0 then
    return {}
  end

  local file, err = io.open(bookmark_path, 'r')
  if not file then
    vim.notify('Failed to read bookmark file: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Notes' })
    return nil
  end

  local content = file:read('*a')
  file:close()

  if not content or content == '' then
    return {}
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify('Failed to decode bookmark file: ' .. tostring(data), vim.log.levels.ERROR, { title = 'Notes' })
    return nil
  end

  return data
end

--- List available bookmark names in the bookmark directory
---@return string[] names List of bookmark names (without .json extension)
function M.list()
  local dir = M.get_bookmark_dir()
  if vim.fn.isdirectory(dir) == 0 then
    return {}
  end

  local files = vim.fn.readdir(dir)
  return vim
    .iter(files)
    :filter(function(f) return f:match('%.json$') end)
    :map(function(f) return (f:gsub('%.json$', '')) end)
    :totable()
end

--- Get the current active bookmark path from the session variable.
--- Falls back to the default bookmark file if no session variable is set.
---@return string path The current bookmark file path
function M.get_current_path() return vim.g.notes_current_bookmark or M.get_bookmark_path('default') end

--- Set the current active bookmark path in the session variable
---@param path string The bookmark path to set as current
function M.set_current_path(path) vim.g.notes_current_bookmark = path end

--- Prompt user to create a new bookmark and switch to it
---@param on_created fun(path: string)? Optional callback after creation
function M.create_new(on_created)
  vim.ui.input({ prompt = 'New Notes Bookmark: ' }, function(input)
    if not input or input:match('^%s*$') then
      return
    end

    local path = M.get_bookmark_path(input)
    if not M.ensure_dir() then
      return
    end

    -- Save empty data to create the file
    if not M.save(path, {}) then
      return
    end

    vim.notify('Created bookmark: ' .. input, vim.log.levels.INFO, { title = 'Notes' })

    if on_created then
      on_created(path)
    end
  end)
end

--- Show a Snacks picker to select an existing bookmark
---@param on_selected fun(path: string)? Optional callback after selection
function M.select_existing(on_selected)
  local names = M.list()

  if #names == 0 then
    vim.notify('No bookmarks found', vim.log.levels.WARN, { title = 'Notes' })
    return
  end

  ---@type snacks.picker.finder.Item[]
  local items = {}
  for idx, name in ipairs(names) do
    items[#items + 1] = {
      formatted = name,
      text = idx .. '. ' .. name,
      item = name,
      idx = idx,
    }
  end

  Snacks.picker.pick({
    source = 'select',
    items = items,
    format = 'text',
    title = 'Select Notes Bookmark',
    preview = function(ctx)
      ctx.preview:reset()
      local name = ctx.item.item
      local path = M.get_bookmark_path(name)
      local data = M.load(path)

      if not data or vim.tbl_isempty(data) then
        ctx.preview:set_lines({ '  No notes in this bookmark' })
        return
      end

      local lines = {}
      local ns = ctx.preview:ns()
      local hl_ranges = {}

      for fpath, notes in pairs(data) do
        local short = vim.fn.fnamemodify(fpath, ':~:.')
        table.insert(hl_ranges, { line = #lines, group = 'Directory' })
        table.insert(lines, '  ' .. short)

        for _, note in ipairs(notes) do
          local prefix = '    L' .. (note.line + 1) .. ': '
          table.insert(hl_ranges, { line = #lines, col = 0, end_col = #prefix, group = 'LineNr' })
          table.insert(hl_ranges, { line = #lines, col = #prefix, group = 'DiagnosticHint' })
          table.insert(lines, prefix .. note.text)
        end

        table.insert(lines, '')
      end

      ctx.preview:set_lines(lines)

      for _, hl in ipairs(hl_ranges) do
        vim.api.nvim_buf_set_extmark(ctx.buf, ns, hl.line, hl.col or 0, {
          end_row = hl.line,
          end_col = hl.end_col or #lines[hl.line + 1],
          hl_group = hl.group,
        })
      end
    end,
    layout = { preset = 'telescope_vertical' },
    actions = {
      remove = function(picker)
        local selected = picker:selected({ fallback = true })
        vim.iter(selected):each(function(item)
          local path = M.get_bookmark_path(item.item)
          os.remove(path)
        end)
        picker:close()
        vim.notify('Removed selected bookmarks', vim.log.levels.INFO, { title = 'Notes' })
      end,
      confirm = function(picker, item)
        picker:close()
        local path = M.get_bookmark_path(item.item)
        if on_selected then
          on_selected(path)
        end
      end,
    },
    win = { input = { keys = { ['<c-x>'] = { 'remove', mode = { 'i', 'n' } } } } },
  })
end

--- Save the current bookmark path to a session variable (for persistence across sessions)
---@return string encoded JSON-encoded session state
function M.save_session_state()
  local state = {
    current_bookmark = M.get_current_path(),
  }
  local encoded = vim.json.encode(state)
  vim.g.NotesSessionState = encoded
  return encoded
end

--- Load the bookmark path from the session variable
---@return string? bookmark_path The restored bookmark path, or nil
function M.load_session_state()
  local encoded = vim.g.NotesSessionState
  if not encoded or encoded == '' then
    return nil
  end

  local ok, state = pcall(vim.json.decode, encoded)
  if not ok or not state then
    return nil
  end

  return state.current_bookmark
end

return M
