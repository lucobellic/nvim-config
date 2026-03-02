--- Notes utility plugin for Neovim.
--- Allows adding, deleting, and searching inline notes as extmarks.
--- Notes are stored in an in-memory store and persisted to bookmark
--- files (JSON) on BufLeave and VimLeavePre/QuitPre.
--- Extmarks track line movements; positions are synced back to the
--- store before each save.
---
---@class NotesModule
---@field private config NotesConfig Plugin configuration
---@field private loaded_buffers table<number, boolean> Set of buffer handles with extmarks restored
local M = {
  config = {},
  loaded_buffers = {},
}

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

--- Collect extmark positions from all loaded buffers into the store.
--- This ensures the store has the latest line numbers before saving.
local function collect_all_to_store()
  local extmarks = require('notes.extmarks')
  vim
    .iter(pairs(M.loaded_buffers))
    :filter(function(bufnr, _) return vim.api.nvim_buf_is_valid(bufnr) end)
    :each(function(bufnr, _)
      local path = buf_path(bufnr)
      if path then
        extmarks.collect_to_store(bufnr, path)
      end
    end)
end

--- Save the in-memory store to the current bookmark file on disk.
--- Collects extmark positions first, then writes.
function M.save_current_bookmark()
  local bookmarks = require('notes.bookmarks')
  local store = require('notes.store')

  collect_all_to_store()

  local current_path = bookmarks.get_current_path()
  local data = store.to_data()
  bookmarks.save(current_path, data)
  store.mark_clean()
end

--- Load notes from the store into a buffer's extmarks.
--- On first load for a buffer, restores extmarks from the in-memory store.
---@param bufnr number Buffer handle
function M.load_buffer_notes(bufnr)
  if M.loaded_buffers[bufnr] then
    return
  end

  local path = buf_path(bufnr)
  if not path then
    return
  end

  local extmarks = require('notes.extmarks')
  extmarks.sync_from_store(bufnr, path)
  M.loaded_buffers[bufnr] = true
end

--- Add a note on the current cursor line.
--- If a note already exists on the line, its text is pre-filled for editing.
function M.add_note()
  local extmarks = require('notes.extmarks')
  local store = require('notes.store')
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed
  local path = buf_path(bufnr)

  if not path then
    return
  end

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
        store.delete_note(path, existing.line)
        vim.notify('Note deleted', vim.log.levels.INFO, { title = 'Notes' })
      end
      return
    end

    -- Update both extmarks (visual) and store (source of truth)
    extmarks.set_note(bufnr, line, input)
    store.upsert_note(path, line, input)
  end)
end

--- Delete the note on the current cursor line
function M.delete_note()
  local extmarks = require('notes.extmarks')
  local store = require('notes.store')
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local path = buf_path(bufnr)

  if not path then
    return
  end

  local existing = extmarks.get_note_at_line(bufnr, line)
  if not existing then
    vim.notify('No note on this line', vim.log.levels.WARN, { title = 'Notes' })
    return
  end

  -- Delete from both extmarks and store
  extmarks.delete_note(bufnr, existing.extmark_id)
  store.delete_note(path, existing.line)
  vim.notify('Note deleted', vim.log.levels.INFO, { title = 'Notes' })
end

--- Switch to a different bookmark session.
--- Saves the current bookmark, clears the store and all extmarks,
--- then loads the new bookmark into the store and restores extmarks.
---@param new_path string Full path to the new bookmark JSON file
function M.change_bookmark(new_path)
  -- Save current bookmark first
  M.save_current_bookmark()

  -- Clear all extmarks from loaded buffers
  local extmarks = require('notes.extmarks')
  for bufnr, _ in pairs(M.loaded_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      extmarks.clear_buffer(bufnr)
    end
  end
  M.loaded_buffers = {}

  -- Clear and reload the store
  local store = require('notes.store')
  local bookmarks = require('notes.bookmarks')
  store.clear()

  -- Set new bookmark path
  bookmarks.set_current_path(new_path)

  -- Load new bookmark data into the store
  local data = bookmarks.load(new_path)
  store.load_from_data(data or {})

  -- Restore extmarks for currently open buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and buf_path(bufnr) then
      M.load_buffer_notes(bufnr)
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

--- Jump to a note in the specified direction
---@param direction 'next'|'prev' Direction to jump
local function jump_note(direction)
  local extmarks = require('notes.extmarks')
  local bufnr = vim.api.nvim_get_current_buf()
  local current_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed

  local notes = extmarks.get_all_notes(bufnr)
  if #notes == 0 then
    return
  end

  table.sort(notes, function(a, b) return a.line < b.line end)

  local target_note = nil
  if direction == 'next' then
    for _, note in ipairs(notes) do
      if note.line > current_line then
        target_note = note
        break
      end
    end
    target_note = target_note or notes[1]
  else
    for i = #notes, 1, -1 do
      if notes[i].line < current_line then
        target_note = notes[i]
        break
      end
    end
    target_note = target_note or notes[#notes]
  end

  vim.api.nvim_win_set_cursor(0, { target_note.line + 1, 0 })
end

--- Jump to the next note extmark in the current buffer (cycles to first if at end)
function M.jump_next() jump_note('next') end

--- Jump to the previous note extmark in the current buffer (cycles to last if at start)
function M.jump_prev() jump_note('prev') end

--- Setup the notes plugin with the given configuration
---@param opts? NotesConfig User configuration (merged with defaults)
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', defaults, opts or {})

  local extmarks = require('notes.extmarks')
  local bookmarks = require('notes.bookmarks')
  local store = require('notes.store')

  extmarks.init(M.config)
  bookmarks.init(M.config)

  -- Restore session state (bookmark path from previous session)
  local restored_path = bookmarks.load_session_state()
  if restored_path then
    bookmarks.set_current_path(restored_path)
  end

  -- Load the current bookmark data into the in-memory store (single disk read)
  local current_path = bookmarks.get_current_path()
  local data = bookmarks.load(current_path)
  store.load_from_data(data or {})

  local group = vim.api.nvim_create_augroup('Notes', { clear = true })

  -- Load extmarks when entering a buffer (reads from store, no disk I/O)
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    callback = function(ev) M.load_buffer_notes(ev.buf) end,
    desc = 'Restore extmarks for buffer from in-memory store',
  })

  -- Collect extmark positions and save to disk on buffer leave
  if M.config.auto_save then
    vim.api.nvim_create_autocmd('BufLeave', {
      group = group,
      callback = function(ev)
        local path = buf_path(ev.buf)
        if path and M.loaded_buffers[ev.buf] then
          extmarks.collect_to_store(ev.buf, path)
          -- Only write to disk if something changed
          if store.is_dirty() then
            local bm_path = bookmarks.get_current_path()
            bookmarks.save(bm_path, store.to_data())
            store.mark_clean()
          end
        end
      end,
      desc = 'Sync extmark positions to store and save to disk',
    })
  end

  -- Fallback save before vim exits
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
