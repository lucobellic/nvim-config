local M = {}

--- Collect extmark positions for all loaded buffers into the store
--- so the picker always shows the latest line numbers.
local function sync_loaded_buffers()
  local notes_mod = require('notes')
  local extmarks = require('notes.extmarks')
  vim
    .iter(pairs(notes_mod.loaded_buffers))
    :filter(function(bufnr, _) return vim.api.nvim_buf_is_valid(bufnr) end)
    :each(function(bufnr, _)
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= '' then
        local path = vim.fn.fnamemodify(name, ':p')
        extmarks.collect_to_store(bufnr, path)
      end
    end)
end

--- Format a note picker item with index, note text, and filename highlights.
--- @param item snacks.picker.finder.Item
--- @param picker snacks.Picker
--- @return snacks.picker.Highlight[]
local function format_note_item(item, picker)
  ---@type snacks.picker.Highlight[]
  local highlights = {
    { tostring(item.idx) .. ' ', 'Normal', virtual = true },
    { item.item.text .. ' ', 'DiagnosticHint', virtual = true },
  }
  return vim.list_extend(highlights, Snacks.picker.format.filename(item, picker))
end

---@return snacks.picker.finder.Item[]
local function notes_finder()
  local store = require('notes.store')

  -- Sync extmark positions before reading
  sync_loaded_buffers()

  local data = store.to_data()

  local items = vim
    .iter(data or {})
    :enumerate()
    :map(function(idx, path, notes)
      local short_path = vim.fn.fnamemodify(path, ':~:.')
      return vim
        .iter(notes or {})
        :map(function(note)
          idx = idx + 1
          return {
            formatted = short_path .. ':' .. (note.line + 1) .. ' ' .. note.text,
            text = idx .. ' ' .. short_path .. ':' .. (note.line + 1) .. ' ' .. note.text,
            file = path,
            pos = { note.line + 1, 0 },
            item = note,
            idx = idx,
          }
        end)
        :totable()
    end)
    :totable()

  return vim.iter(items):flatten():totable()
end

--- Refresh extmarks for a buffer if it is currently loaded.
---@param file string Absolute file path
local function refresh_buffer_extmarks(file)
  local notes_mod = require('notes')
  local extmarks = require('notes.extmarks')

  -- Find the loaded buffer for this file
  local bufnr = vim.fn.bufnr(file)
  if bufnr ~= -1 and notes_mod.loaded_buffers[bufnr] and vim.api.nvim_buf_is_valid(bufnr) then
    extmarks.sync_from_store(bufnr, file)
  end
end

--- Internal function to create a notes picker with optional cwd filter
---@param opts? snacks.picker.filter.Config
local function create_notes_picker(opts)
  opts = opts or {}
  local store = require('notes.store')
  local extmarks = require('notes.extmarks')
  local notes_mod = require('notes')

  Snacks.picker.pick({
    source = 'select',
    format = format_note_item,
    layout = { preset = 'telescope_vertical' },
    title = opts.cwd and 'Notes' or 'Notes (All)',
    filter = opts,
    finder = function(_, ctx) return ctx.filter:filter(notes_finder()) end,
    actions = {
      confirm = function(picker, item)
        picker:close()
        vim.schedule(function()
          if vim.fn.filereadable(item.file) == 1 then
            vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
            vim.api.nvim_win_set_cursor(0, item.pos)
          else
            vim.notify('File not found: ' .. item.file, vim.log.levels.ERROR, { title = 'Notes' })
          end
        end)
      end,
      remove = function(picker)
        local selected = picker:selected({ fallback = true })
        vim.iter(selected):each(function(item)
          -- Delete from store (works regardless of buffer load state)
          store.delete_note(item.file, item.item.line)
          -- If buffer is loaded, also remove the extmark visually
          local bufnr = vim.fn.bufnr(item.file)
          if bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr) and notes_mod.loaded_buffers[bufnr] then
            local note = extmarks.get_note_at_line(bufnr, item.item.line)
            if note then
              extmarks.delete_note(bufnr, note.extmark_id)
            end
          end
        end)

        -- Save to disk after deletion
        notes_mod.save_current_bookmark()

        picker.list:set_selected()
        picker.list:set_target()
        picker:find()
      end,
      edit = function(picker)
        local selected = picker:selected({ fallback = true })[1]
        if not selected then
          return
        end
        vim.ui.input({ prompt = 'Edit Note: ', default = selected.item.text }, function(input)
          if input == nil then
            return
          end

          if input:match('^%s*$') then
            -- Empty input: delete the note from store
            store.delete_note(selected.file, selected.item.line)
            -- Remove extmark if buffer is loaded
            local bufnr = vim.fn.bufnr(selected.file)
            if bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr) and notes_mod.loaded_buffers[bufnr] then
              local note = extmarks.get_note_at_line(bufnr, selected.item.line)
              if note then
                extmarks.delete_note(bufnr, note.extmark_id)
              end
            end
          else
            -- Non-empty input: update in store
            store.upsert_note(selected.file, selected.item.line, input)
            -- Refresh extmarks if buffer is loaded
            refresh_buffer_extmarks(selected.file)
          end

          -- Save to disk
          notes_mod.save_current_bookmark()

          picker.list:set_selected()
          picker.list:set_target()
          picker:find()
        end)
      end,
    },
    win = {
      input = {
        keys = {
          ['<c-x>'] = { 'remove', mode = { 'i', 'n' } },
          ['<c-e>'] = { 'edit', mode = { 'i', 'n' } },
        },
      },
    },
  })
end

--- Search and jump to notes in the current working directory (cwd).
--- Uses Snacks picker to display notes filtered to cwd with file path and line number.
function M.search_notes() create_notes_picker({ cwd = true }) end

--- Search and jump to notes across all files in the current bookmark.
--- Uses Snacks picker to display all notes with file path and line number.
function M.search_all_notes() create_notes_picker({ cwd = false }) end

return M
