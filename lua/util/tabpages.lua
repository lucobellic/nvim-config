---@diagnostic disable: redundant-parameter
---@module 'snacks.picker'

---@class TabUtil
local M = {}

---@enum tab_direction
local tab_direction = {
  next = 'next',
  prev = 'prev',
}

--- Get all `buflisted` buffers
---@return number[] listed_buffers
function M.nvim_list_buflisted()
  return vim
    .iter(vim.fn.getbufinfo({ buflisted = 1 } or {}))
    :filter(function(buffer) return vim.api.nvim_buf_is_valid(buffer.bufnr) end)
    :filter(function(buffer) return vim.api.nvim_get_option_value('filetype', { buf = buffer.bufnr }) ~= '' end)
    :map(function(buffer) return buffer.bufnr end)
    :totable()
end

--- Focus to the window with the first `buflisted` buffer in the current tab if any
function M.focus_first_listed_buffer()
  local listed_buffers = M.nvim_list_buflisted()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  for _, window in pairs(windows) do
    local window_buffer = vim.api.nvim_win_get_buf(window)
    for _, listed_buffer in pairs(listed_buffers) do
      if window_buffer == listed_buffer then
        vim.api.nvim_set_current_win(window)
        return
      end
    end
  end
end

---@param list any[]
---@param item any
---@return any?
function M.find_first_different(list, item)
  for _, v in pairs(list) do
    if v ~= item then
      return v
    end
  end
end

--- Move current buffer to the next or previous tabpage.
--- Create a new tabpage if there is only one tabpage.
---@param direction tab_direction tabpage direction
---@param focus? Optional<boolean> focus buffer after moving it
function M.move_buffer_to_tab(direction, focus)
  focus = focus or false
  local buffer_to_move = vim.api.nvim_get_current_buf()
  local nb_tabpages = #vim.api.nvim_list_tabpages()
  local listed_buffers = M.nvim_list_buflisted()
  local nb_listed_buffers = #listed_buffers

  -- Do nothing if there is only one tabpage and one listed buffer
  if nb_tabpages == 1 and nb_listed_buffers == 1 then
    return
  end

  -- Hide buffer from the buffer line
  vim.api.nvim_set_option_value('buflisted', false, { buf = buffer_to_move })

  -- Select the next buffer as active if any
  local next_buffer = M.find_first_different(listed_buffers, buffer_to_move)
  if next_buffer then
    vim.api.nvim_set_current_buf(next_buffer)
  end

  -- Close the tabpage if there is only one listed buffer
  if nb_listed_buffers == 1 then
    vim.cmd('tabclose')
    if direction == tab_direction.next then
      vim.cmd('tabnext')
    end
  elseif nb_tabpages == 1 then
    vim.cmd(direction == tab_direction.prev and '-tabnew' or 'tabnew')
  else
    vim.cmd(direction == tab_direction.prev and 'tabprevious' or 'tabnext')
  end

  -- Re-enable the buffer
  vim.api.nvim_set_option_value('buflisted', true, { buf = buffer_to_move })

  -- Focus buffer after moving it
  if focus then
    vim.api.nvim_set_current_buf(buffer_to_move)
  end
end

--- Build a list of picker items representing all valid tabpages.
--- Each item exposes the tabpage handle and a display label combining the tab
--- number with its optional name (stored in `t:name` via scope / bufferline).
---@return snacks.picker.finder.Item[]
local function get_tabpage_items()
  return vim
    .iter(vim.api.nvim_list_tabpages())
    :filter(function(tab) return vim.api.nvim_tabpage_is_valid(tab) end)
    :map(function(tab)
      local tabnr = vim.api.nvim_tabpage_get_number(tab)
      local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, 'name')
      local label = ok and name and ('[%d] %s'):format(tabnr, name) or ('[%d]'):format(tabnr)
      return { text = label, tabpage = tab, tabnr = tabnr }
    end)
    :totable()
end

--- Move a list of buffers into a target tabpage by directly updating the scope
--- cache and toggling `buflisted`.
---
--- `scope.core.move_buf` has a bug where it builds a fresh local table for tabs
--- with no cache entry yet and never stores it back, so buffers moved to a brand
--- new tab are silently dropped.  We work around this by writing to
--- `scope.core.cache[target]` directly.
---
--- Focus stays on the originating tab — the caller is responsible for not
--- switching tabs before calling this function.
---@param bufnrs number[] Buffer handles to move
---@param target_tabpage number Target tabpage handle
local function do_move_buffers(bufnrs, target_tabpage)
  local scope_core = require('scope.core')
  local current_tab = vim.api.nvim_get_current_tabpage()

  -- Ensure the target tab has a cache table before we append to it.
  if not scope_core.cache[target_tabpage] then
    scope_core.cache[target_tabpage] = {}
  end
  local target_cache = scope_core.cache[target_tabpage]

  vim.iter(bufnrs):each(function(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    -- Register buffer in target tab's scope cache (avoid duplicates).
    if not vim.tbl_contains(target_cache, bufnr) then
      target_cache[#target_cache + 1] = bufnr
    end

    -- Remove buffer from current tab's scope cache.
    if scope_core.cache[current_tab] then
      scope_core.cache[current_tab] = vim
        .iter(scope_core.cache[current_tab])
        :filter(function(b) return b ~= bufnr end)
        :totable()
    end

    -- Unlist the buffer so it disappears from the current tab's bufferline.
    -- It will become listed again when the target tab is entered (on_tab_enter).
    local listed_in_current = vim.api.nvim_get_option_value('buflisted', { buf = bufnr })
    if listed_in_current then
      -- Switch away from the buffer if it is currently displayed.
      local win = vim.fn.bufwinid(bufnr)
      if win ~= -1 and vim.api.nvim_win_is_valid(win) then
        local others = M.nvim_list_buflisted()
        local next_buf = M.find_first_different(others, bufnr)
        if next_buf then
          vim.api.nvim_win_set_buf(win, next_buf)
        end
      end
      vim.api.nvim_set_option_value('buflisted', false, { buf = bufnr })
    end
  end)
end

--- Open a buffer picker to select buffers, then move them to an existing or new tabpage.
---
--- Workflow:
---   - Use `<Tab>` / `<S-Tab>` to multi-select buffers.
---   - Press `<CR>`   → pick an **existing** tabpage from a second picker and move the
---                       selected buffers there.
---   - Press `<C-CR>` → enter a **new tab name** via `vim.ui.input`, create the tab,
---                       and move the selected buffers into it.
function M.move_buffers_to_tab()
  --- Extract buffer handles from a list of picker items.
  ---@param items snacks.picker.finder.Item[]
  ---@return number[]
  local function extract_bufnrs(items)
    return vim.iter(items):map(function(item) return item.buf end):totable()
  end

  Snacks.picker.buffers({
    title = 'Select Buffers to Move',
    actions = {
      --- Confirm action: open existing tabpage picker, then move selected buffers.
      ---@param picker snacks.Picker
      confirm_existing_tab = function(picker)
        local selected = picker:selected({ fallback = true })
        picker:close()
        if not selected or #selected == 0 then
          return
        end
        local bufnrs = extract_bufnrs(selected)

        Snacks.picker.pick({
          title = 'Move Buffers to Tab',
          items = get_tabpage_items(),
          format = 'text',
          layout = { preset = 'vscode' },
          confirm = function(tab_picker, tab_item)
            tab_picker:close()
            if tab_item then
              do_move_buffers(bufnrs, tab_item.tabpage)
            end
          end,
        })
      end,

      --- Shift-confirm action: prompt for a new tab name, create it, then move selected buffers.
      ---@param picker snacks.Picker
      confirm_new_tab = function(picker)
        local selected = picker:selected({ fallback = true })
        picker:close()
        if not selected or #selected == 0 then
          return
        end
        local bufnrs = extract_bufnrs(selected)
        -- Capture originating tab before any tab switch.
        local origin_tab = vim.api.nvim_get_current_tabpage()

        vim.ui.input({ prompt = 'New tab name: ' }, function(name)
          if not name or name == '' then
            return
          end
          vim.cmd('tabnew')
          local new_tab = vim.api.nvim_get_current_tabpage()
          vim.api.nvim_tabpage_set_var(new_tab, 'name', name)
          pcall(vim.cmd, 'BufferLineTabRename ' .. name)

          -- Return focus to the originating tab before moving buffers,
          -- so do_move_buffers sees the correct current tab in scope.core.
          vim.api.nvim_set_current_tabpage(origin_tab)
          do_move_buffers(bufnrs, new_tab)
        end)
      end,
    },
    win = {
      input = {
        keys = {
          ['<CR>'] = { 'confirm_existing_tab', mode = { 'i', 'n' } },
          ['<C-CR>'] = { 'confirm_new_tab', mode = { 'i', 'n' } },
        },
      },
    },
  })
end

return M
