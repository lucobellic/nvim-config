---@class NotesExtmarks
---@field private ns_id number Namespace id for notes extmarks
---@field private config NotesConfig Reference to plugin configuration
---@field visible boolean Whether notes are currently visible
---@field private note_metadata table<number, table<number, string>> Map of bufnr -> extmark_id -> note_text
local M = {}

M.ns_id = vim.api.nvim_create_namespace('notes')
M.visible = true
M.note_metadata = {}

--- Initialize extmarks module with config reference
---@param config NotesConfig
function M.init(config) M.config = config end

--- Get metadata table for a buffer
---@param bufnr number Buffer handle
---@return table<number, string> metadata Map of extmark_id -> note_text
local function get_buffer_metadata(bufnr)
  if not M.note_metadata[bufnr] then
    M.note_metadata[bufnr] = {}
  end
  return M.note_metadata[bufnr]
end

--- Build the virt_text table for a note extmark
---@param text string The note text
---@return table virt_text The virt_text parameter for nvim_buf_set_extmark
function M.build_virt_text(text)
  local config = M.config
  return {
    { config.prefix .. text .. config.suffix, config.text_hl },
  }
end

--- Set a note extmark on a buffer line. One note per line; if a note already
--- exists on the target line its extmark is replaced.
---@param bufnr number Buffer handle
---@param line number 0-indexed line number
---@param text string Note content
---@return number extmark_id The created extmark id
function M.set_note(bufnr, line, text)
  -- Remove any existing note on this line first
  local existing = M.get_note_at_line(bufnr, line)
  if existing then
    vim.api.nvim_buf_del_extmark(bufnr, M.ns_id, existing.extmark_id)
    -- Clean up metadata for the old extmark
    local metadata = get_buffer_metadata(bufnr)
    metadata[existing.extmark_id] = nil
  end

  local extmark_opts = vim.tbl_deep_extend('force', {
    virt_text = M.visible and M.build_virt_text(text) or {},
    virt_text_pos = 'eol',
    hl_mode = 'combine',
  }, M.config.extmark or {})

  -- Always override virt_text based on visibility
  extmark_opts.virt_text = M.visible and M.build_virt_text(text) or {}

  local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, line, 0, extmark_opts)

  -- Store the raw note text in metadata
  local metadata = get_buffer_metadata(bufnr)
  metadata[extmark_id] = text

  return extmark_id
end

--- Get the note at a specific line (0-indexed).
--- Returns nil if no note exists on that line.
---@param bufnr number Buffer handle
---@param line number 0-indexed line number
---@return Note? note The note at the given line, or nil
function M.get_note_at_line(bufnr, line)
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, M.ns_id, { line, 0 }, { line, -1 }, { details = true })
  if #marks == 0 then
    return nil
  end

  local mark = marks[1]
  local extmark_id = mark[1]
  local metadata = get_buffer_metadata(bufnr)
  local text = metadata[extmark_id] or M.extract_text(mark[4])

  return {
    line = mark[2],
    text = text,
    extmark_id = extmark_id,
  }
end

--- Extract note text from extmark details, stripping prefix and suffix
---@param details table Extmark details from nvim_buf_get_extmarks
---@return string text The raw note text
function M.extract_text(details)
  -- Extract from virt_text
  local virt_text = details.virt_text
  if not virt_text or #virt_text == 0 then
    return ''
  end

  local raw = virt_text[1][1] or ''
  local config = M.config

  -- Strip prefix
  if config.prefix and #config.prefix > 0 and raw:sub(1, #config.prefix) == config.prefix then
    raw = raw:sub(#config.prefix + 1)
  end

  -- Strip suffix
  if config.suffix and #config.suffix > 0 and raw:sub(-#config.suffix) == config.suffix then
    raw = raw:sub(1, -(#config.suffix + 1))
  end

  return raw
end

--- Get all notes in a buffer with their current extmark positions.
--- Positions reflect any line movements since the extmarks were created.
---@param bufnr number Buffer handle
---@return Note[] notes List of notes with current positions
function M.get_all_notes(bufnr)
  local marks = vim.api.nvim_buf_get_extmarks(bufnr, M.ns_id, 0, -1, { details = true })
  local metadata = get_buffer_metadata(bufnr)

  ---@type Note[]
  local notes = {}
  for _, mark in ipairs(marks) do
    local extmark_id = mark[1]
    local details = mark[4]
    -- Prefer metadata, fallback to extracting from virt_text
    local text = metadata[extmark_id] or M.extract_text(details)
    table.insert(notes, {
      line = mark[2],
      text = text,
      extmark_id = extmark_id,
    })
  end

  return notes
end

--- Delete a single note by extmark id
---@param bufnr number Buffer handle
---@param extmark_id number Extmark identifier
function M.delete_note(bufnr, extmark_id)
  vim.api.nvim_buf_del_extmark(bufnr, M.ns_id, extmark_id)
  -- Clean up metadata
  local metadata = get_buffer_metadata(bufnr)
  metadata[extmark_id] = nil
end

--- Clear all notes from a buffer
---@param bufnr number Buffer handle
function M.clear_buffer(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
  -- Clear metadata for this buffer
  M.note_metadata[bufnr] = nil
end

--- Restore notes from saved data into a buffer
---@param bufnr number Buffer handle
---@param notes SavedNote[] List of saved notes to restore
function M.restore_notes(bufnr, notes)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for _, note in ipairs(notes) do
    if note.line < line_count then
      M.set_note(bufnr, note.line, note.text)
    end
  end
end

--- Refresh all extmarks in a buffer to update visibility
---@param bufnr number Buffer handle
function M.refresh_buffer(bufnr)
  local notes = M.get_all_notes(bufnr)
  for _, note in ipairs(notes) do
    M.set_note(bufnr, note.line, note.text)
  end
end

--- Set visibility state and refresh all buffers
---@param visible boolean Whether notes should be visible
---@param loaded_buffers table<number, boolean> Set of loaded buffer handles
function M.set_visible(visible, loaded_buffers)
  M.visible = visible
  -- Refresh all loaded buffers to apply visibility change
  for bufnr, _ in pairs(loaded_buffers) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.refresh_buffer(bufnr)
    end
  end
end

return M
