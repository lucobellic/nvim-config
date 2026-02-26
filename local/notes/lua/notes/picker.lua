local M = {}

---@return snacks.picker.finder.Item[]
local function notes_finder()
  local bookmarks = require('notes.bookmarks')
  local current_path = bookmarks.get_current_path()
  local data = bookmarks.load(current_path)

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

--- Internal function to create a notes picker with optional cwd filter
---@param opts? snacks.picker.filter.Config
local function create_notes_picker(opts)
  opts = opts or {}
  local extmarks = require('notes.extmarks')

  -- First save current state so we have up-to-date positions
  require('notes').save_current_bookmark()

  Snacks.picker.pick({
    source = 'select',
    format = 'text',
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
        vim
          .iter(selected)
          :map(function(item)
            local bufnr = vim.fn.bufnr(item.file)
            return {
              bufnr = bufnr,
              file = item.file,
              item = item,
              note = extmarks.get_note_at_line(bufnr, item.item.line),
            }
          end)
          :filter(function(entry) return vim.api.nvim_buf_is_valid(entry.bufnr) and entry.note ~= nil end)
          :each(function(entry) extmarks.delete_note(entry.bufnr, entry.note.extmark_id) end)

        -- Re-save after deletion
        require('notes').save_current_bookmark()

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

          -- Get or load the buffer for this file
          local bufnr = vim.fn.bufnr(selected.file)
          if bufnr == -1 then
            vim.cmd('badd ' .. vim.fn.fnameescape(selected.file))
            bufnr = vim.fn.bufnr(selected.file)
          end

          -- Ensure notes are loaded for this buffer
          require('notes').load_buffer_notes(bufnr)

          if input:match('^%s*$') then
            -- Empty input: delete the note
            local note = extmarks.get_note_at_line(bufnr, selected.item.line)
            if note then
              extmarks.delete_note(bufnr, note.extmark_id)
            end
          else
            -- Non-empty input: update the note
            extmarks.set_note(bufnr, selected.item.line, input)
          end

          -- Mark buffer as modified so changes are tracked
          M.loaded_buffers[bufnr] = true

          -- Save changes
          require('notes').save_current_bookmark()

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
