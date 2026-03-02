--- In-memory store for notes.
--- This module is the single source of truth for all note data.
--- Notes are stored as a map of absolute file paths to their notes.
--- The store is populated from disk on startup and written back on
--- specific events (BufLeave, VimLeavePre/QuitPre).
---
---@class NotesStore
---@field private data BookmarkData Map of absolute file paths to their notes
---@field private dirty boolean Whether the store has unsaved changes
local M = {
  data = {},
  dirty = false,
}

--- Clear the entire store
function M.clear()
  M.data = {}
  M.dirty = false
end

--- Check if the store has unsaved changes
---@return boolean dirty
function M.is_dirty() return M.dirty end

--- Mark the store as clean (after a successful save)
function M.mark_clean() M.dirty = false end

--- Bulk-populate the store from a BookmarkData table (loaded from disk).
--- Replaces the current contents entirely.
---@param bookmark_data BookmarkData
function M.load_from_data(bookmark_data)
  M.data = bookmark_data or {}
  M.dirty = false
end

--- Serialize the store contents to a BookmarkData table for writing to disk.
--- Only includes paths that have at least one note.
---@return BookmarkData data
function M.to_data()
  ---@type BookmarkData
  local result = {}
  vim
    .iter(pairs(M.data))
    :filter(function(_, notes) return notes and #notes > 0 end)
    :each(function(path, notes) result[path] = notes end)
  return result
end

--- Get all notes for a given file path.
---@param path string Absolute file path
---@return SavedNote[] notes (empty table if no notes exist)
function M.get(path) return M.data[path] or {} end

--- Replace all notes for a given file path.
---@param path string Absolute file path
---@param notes? SavedNote[] The notes to set
function M.set(path, notes)
  M.data[path] = (notes and #notes > 0) and notes or nil
  M.dirty = true
end

--- Add or update a note at a specific line for a file path.
--- If a note already exists on the line, it is replaced.
---@param path string Absolute file path
---@param line number 0-indexed line number
---@param text string Note content
function M.upsert_note(path, line, text)
  local notes = M.data[path] or {}

  -- Replace existing note on the same line, or append
  local index = vim
    .iter(ipairs(notes))
    :filter(function(_, note) return note.line == line end)
    :map(function(i, _) return i end)
    :nth(1)

  if not index then
    table.insert(notes, { line = line, text = text })
  else
    notes[index] = { line = line, text = text }
  end

  M.data[path] = notes
  M.dirty = true
end

--- Delete a note at a specific line for a file path.
--- Works regardless of whether the buffer is loaded.
---@param path string Absolute file path
---@param line number 0-indexed line number
---@return boolean deleted Whether a note was actually removed
function M.delete_note(path, line)
  local notes = M.data[path]
  if not notes then
    return false
  end

  local new_notes = vim.iter(notes):filter(function(note) return note.line ~= line end):totable()

  M.data[path] = #new_notes > 0 and new_notes or nil

  local deleted = #new_notes < #notes
  if deleted then
    M.dirty = true
  end

  return deleted
end

--- Update the stored line numbers for a file path from extmark positions.
--- This is called when leaving a buffer to capture any line movements
--- that extmarks have tracked.
---@param path string Absolute file path
---@param notes SavedNote[] Updated notes with current line positions
function M.update_positions(path, notes)
  if notes and #notes > 0 then
    M.data[path] = notes
    M.dirty = true
  elseif M.data[path] then
    M.data[path] = nil
    M.dirty = true
  end
end

--- Remove all notes for a given file path.
---@param path string Absolute file path
function M.remove_path(path)
  if M.data[path] then
    M.data[path] = nil
    M.dirty = true
  end
end

return M
