--- Notes utility plugin for Neovim.
--- Allows adding, deleting, and searching inline notes as extmarks.
--- Notes are persisted to bookmark files (JSON) and their positions
--- track line movements via the extmark mechanism.
---
---@class NotesModule
---@field private config NotesConfig Plugin configuration
---@field private loaded_buffers table<number, boolean> Set of buffer handles already loaded
local M = {}

---@class NotesConfig
---@field extmark? vim.api.keyset.set_extmark Options passed to nvim_buf_set_extmark
---@field bookmark_dir string Directory for bookmark JSON files
---@field auto_save? boolean Auto-save notes on buffer changes
---@field prefix? string Prefix for note virtual text
---@field suffix? string Suffix for note virtual text
---@field text_hl? string Highlight group for note text

---@class Note
---@field line number 0-indexed line number
---@field text string Note content
---@field extmark_id number? Extmark identifier (runtime only)

---@class SavedNote
---@field line number 0-indexed line number
---@field text string Note content

---@alias BookmarkData table<string, SavedNote[]> Map of absolute file paths to their notes

---@type NotesConfig
local defaults = {
  extmark = {},
  bookmark_dir = vim.fn.stdpath('data') .. '/notes',
  auto_save = true,
  prefix = '󱙝 ',
  suffix = '',
  text_hl = 'DiagnosticHint',
}

M.loaded_buffers = {}

--- Normalize a buffer name to an absolute path
---@param bufnr number Buffer handle
---@return string? path Absolute path, or nil if buffer has no name
local function buf_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return nil
  end
  return vim.fn.fnamemodify(name, ':p')
end

--- Collect current notes from all loaded buffers
---@return BookmarkData data
local function collect_all_notes()
  local extmarks = require('notes.extmarks')
  ---@type BookmarkData
  local data = {}

  for bufnr, _ in pairs(M.loaded_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      local path = buf_path(bufnr)
      if path then
        local notes = extmarks.get_all_notes(bufnr)
        if #notes > 0 then
          ---@type SavedNote[]
          local saved = {}
          for _, note in ipairs(notes) do
            table.insert(saved, { line = note.line, text = note.text })
          end
          data[path] = saved
        end
      end
    end
  end

  -- Merge with existing bookmark data for buffers not currently loaded
  local bookmarks = require('notes.bookmarks')
  local current_path = bookmarks.get_current_path()
  local existing = bookmarks.load(current_path)
  if existing then
    for fpath, notes in pairs(existing) do
      if data[fpath] == nil then
        -- Check if we tried to load this buffer but it had no notes
        local was_loaded = false
        for bufnr, _ in pairs(M.loaded_buffers) do
          if vim.api.nvim_buf_is_valid(bufnr) and buf_path(bufnr) == fpath then
            was_loaded = true
            break
          end
        end
        -- Keep existing data for buffers we never loaded
        if not was_loaded then
          data[fpath] = notes
        end
      end
    end
  end

  return data
end

--- Load notes from the current bookmark into a specific buffer
---@param bufnr number Buffer handle
local function load_buffer_notes(bufnr)
  if M.loaded_buffers[bufnr] then
    return
  end

  local path = buf_path(bufnr)
  if not path then
    return
  end

  local bookmarks = require('notes.bookmarks')
  local extmarks = require('notes.extmarks')
  local current_path = bookmarks.get_current_path()
  local data = bookmarks.load(current_path)

  if not data or not data[path] then
    M.loaded_buffers[bufnr] = true
    return
  end

  extmarks.restore_notes(bufnr, data[path])
  M.loaded_buffers[bufnr] = true
end

--- Save the current notes to the active bookmark file
function M.save_current_bookmark()
  local bookmarks = require('notes.bookmarks')
  local current_path = bookmarks.get_current_path()
  local data = collect_all_notes()
  bookmarks.save(current_path, data)
end

--- Add a note on the current cursor line.
--- If a note already exists on the line, its text is pre-filled for editing.
function M.add_note()
  local extmarks = require('notes.extmarks')
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed

  -- Check for existing note to pre-fill
  local existing = extmarks.get_note_at_line(bufnr, line)
  local default_text = existing and existing.text or ''

  vim.ui.input({ prompt = 'Note: ', default = default_text }, function(input)
    if input == nil then
      return
    end

    if input:match('^%s*$') then
      -- Empty input: delete the note if one exists
      if existing then
        extmarks.delete_note(bufnr, existing.extmark_id)
        M.loaded_buffers[bufnr] = true
        vim.notify('Note deleted', vim.log.levels.INFO, { title = 'Notes' })
      end
      return
    end

    extmarks.set_note(bufnr, line, input)
    M.loaded_buffers[bufnr] = true
  end)
end

--- Delete the note on the current cursor line
function M.delete_note()
  local extmarks = require('notes.extmarks')
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1

  local existing = extmarks.get_note_at_line(bufnr, line)
  if not existing then
    vim.notify('No note on this line', vim.log.levels.WARN, { title = 'Notes' })
    return
  end

  extmarks.delete_note(bufnr, existing.extmark_id)
  vim.notify('Note deleted', vim.log.levels.INFO, { title = 'Notes' })
end

--- Internal function to create a notes picker with optional cwd filter
---@param opts? { cwd_only?: boolean } Options for the picker
local function create_notes_picker(opts)
  opts = opts or {}
  local bookmarks = require('notes.bookmarks')
  local extmarks = require('notes.extmarks')

  -- First save current state so we have up-to-date positions
  M.save_current_bookmark()

  local current_path = bookmarks.get_current_path()
  local data = bookmarks.load(current_path)

  if not data or vim.tbl_isempty(data) then
    vim.notify('No notes in current bookmark', vim.log.levels.WARN, { title = 'Notes' })
    return
  end

  -- Filter data by cwd if requested
  local filtered_data = data
  if opts.cwd_only then
    local cwd = vim.fn.getcwd()
    filtered_data = {}
    for fpath, notes in pairs(data) do
      if vim.startswith(fpath, cwd .. '/') or fpath == cwd then
        filtered_data[fpath] = notes
      end
    end

    if vim.tbl_isempty(filtered_data) then
      vim.notify('No notes in current directory', vim.log.levels.WARN, { title = 'Notes' })
      return
    end
  end

  local items = vim
    .iter(filtered_data)
    :enumerate()
    :map(function(idx, fpath, notes)
      local short_path = vim.fn.fnamemodify(fpath, ':~:.')
      return vim
        .iter(notes or {})
        :map(function(note)
          idx = idx + 1
          return {
            formatted = short_path .. ':' .. (note.line + 1) .. ' ' .. note.text,
            text = idx .. ' ' .. short_path .. ':' .. (note.line + 1) .. ' ' .. note.text,
            file = fpath,
            pos = { note.line + 1, 0 },
            item = note,
            idx = idx,
          }
        end)
        :totable()
    end):totable()

  ---@type snacks.picker.finder.Item[]
  items = vim.iter(items):flatten():totable()

  if #items == 0 then
    vim.notify('No notes in current bookmark', vim.log.levels.WARN, { title = 'Notes' })
    return
  end

  local title = opts.cwd_only and 'Notes (CWD)' or 'Notes (All)'
  local refresh_fn = opts.cwd_only and M.search_notes or M.search_all_notes

  Snacks.picker.pick({
    source = 'select',
    items = items,
    format = 'text',
    layout = { preset = 'telescope_vertical' },
    title = title,
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
          -- Find the buffer for this file and remove the extmark
          local bufnr = vim.fn.bufnr(item.file)
          if bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr) then
            local note = extmarks.get_note_at_line(bufnr, item.item.line)
            if note then
              extmarks.delete_note(bufnr, note.extmark_id)
            end
          end
        end)
        -- Re-save after deletion
        M.save_current_bookmark()
        picker:close()
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
          load_buffer_notes(bufnr)

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
          M.save_current_bookmark()

          -- Refresh picker to show updated notes
          picker:close()
          vim.schedule(refresh_fn)
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
function M.search_notes() create_notes_picker({ cwd_only = true }) end

--- Search and jump to notes across all files in the current bookmark.
--- Uses Snacks picker to display all notes with file path and line number.
function M.search_all_notes() create_notes_picker({ cwd_only = false }) end

--- Switch to a different bookmark session.
--- Saves the current bookmark, clears all notes, and loads the new one.
---@param new_path string Full path to the new bookmark JSON file
function M.change_bookmark(new_path)
  -- Save current bookmark first
  M.save_current_bookmark()

  -- Clear all notes from loaded buffers
  local extmarks = require('notes.extmarks')
  for bufnr, _ in pairs(M.loaded_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      extmarks.clear_buffer(bufnr)
    end
  end
  M.loaded_buffers = {}

  -- Set new bookmark path
  local bookmarks = require('notes.bookmarks')
  bookmarks.set_current_path(new_path)

  -- Load notes for currently open buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and buf_path(bufnr) then
      load_buffer_notes(bufnr)
    end
  end

  local name = vim.fn.fnamemodify(new_path, ':t:r')
  vim.notify('Switched to bookmark: ' .. name, vim.log.levels.INFO, { title = 'Notes' })
end

--- Prompt user to create a new bookmark and switch to it
function M.create_bookmark()
  local bookmarks = require('notes.bookmarks')
  bookmarks.create_new(function(path) M.change_bookmark(path) end)
end

--- Show picker to select an existing bookmark and switch to it
function M.select_bookmark()
  local bookmarks = require('notes.bookmarks')
  bookmarks.select_existing(function(path) M.change_bookmark(path) end)
end

--- Toggle notes visibility on/off
function M.toggle()
  local extmarks = require('notes.extmarks')
  local new_state = not extmarks.visible
  extmarks.set_visible(new_state, M.loaded_buffers)
  vim.notify(
    string.format('Notes %s', new_state and 'visible' or 'hidden'),
    new_state and vim.log.levels.INFO or vim.log.levels.WARN,
    { title = 'Notes' }
  )
end

--- Setup the notes plugin with the given configuration
---@param opts? NotesConfig User configuration (merged with defaults)
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', defaults, opts or {})

  local extmarks = require('notes.extmarks')
  local bookmarks = require('notes.bookmarks')

  extmarks.init(M.config)
  bookmarks.init(M.config)

  -- Restore session state (bookmark path from previous session)
  local restored_path = bookmarks.load_session_state()
  if restored_path then
    bookmarks.set_current_path(restored_path)
  end

  local group = vim.api.nvim_create_augroup('Notes', { clear = true })

  -- Load notes when entering a buffer
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function(ev) load_buffer_notes(ev.buf) end,
    desc = 'Load notes for buffer from current bookmark',
  })

  -- Auto-save on buffer leave
  if M.config.auto_save then
    vim.api.nvim_create_autocmd('BufLeave', {
      group = group,
      callback = function() M.save_current_bookmark() end,
      desc = 'Auto-save notes to current bookmark',
    })
  end

  -- Fallback save before vim exits (in case QuitPre didn't fire)
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      if not M._exiting then
        M.save_current_bookmark()
        bookmarks.save_session_state()
      end
    end,
    desc = 'Save notes and session state before exit (fallback)',
  })

  -- Save before vim exits (must run before BufDelete clears loaded_buffers)
  -- We save eagerly here and set a flag so the VimLeavePre handler knows
  -- it doesn't need to save again (buffers may be invalid by then).
  vim.api.nvim_create_autocmd('QuitPre', {
    group = group,
    callback = function()
      M.save_current_bookmark()
      bookmarks.save_session_state()
      M._exiting = true
    end,
    desc = 'Save notes before buffers are cleaned up on exit',
  })

  -- Clean up loaded_buffers tracking when buffers are deleted
  vim.api.nvim_create_autocmd('BufDelete', {
    group = group,
    callback = function(ev) M.loaded_buffers[ev.buf] = nil end,
    desc = 'Clean up notes tracking for deleted buffers',
  })
end

return M
