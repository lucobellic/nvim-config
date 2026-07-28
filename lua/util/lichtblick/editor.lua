local indexeddb = require('util.lichtblick.indexeddb')
local layout = require('util.lichtblick.layout')
local project = require('util.lichtblick.project')

---@class Lichtblick.EditorModule
---@field open fun(script: Lichtblick.Script) Open a user script in an editable TypeScript buffer.
---@type Lichtblick.EditorModule
local M = {}
---@type table<string, integer>
local open_buffers = {}

---@param message string
---@param level? integer
local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Lichtblick' }) end

---Return a buffer's contents while preserving its final newline.
---@param bufnr integer
---@return string
local function buffer_source(bufnr)
  local source = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
  if vim.bo[bufnr].endofline then
    source = source .. '\n'
  end
  return source
end

---Persist a script to its local layout and/or IndexedDB origin.
---@param bufnr integer
---@param script Lichtblick.Script
local function save_script(bufnr, script)
  local source = buffer_source(bufnr)
  if script.layout_path then
    local ok, err = layout.save_script(script, source)
    if not ok then
      notify(err, vim.log.levels.ERROR)
      return
    end
  end

  local backup_path
  if script.indexeddb then
    local database_ok, database_result = indexeddb.save_script(script.indexeddb, script.id, source)
    if not database_ok then
      notify(database_result, vim.log.levels.ERROR)
      return
    end
    backup_path = database_result
  end

  vim.bo[bufnr].modified = false
  local message = ('Saved %s to %s'):format(script.name, script.layout_name)
  if backup_path then
    message = message .. ' and synced to IndexedDB; Lichtblick is reloading'
  end
  notify(message)
end

---Replace buffer contents while retaining its final newline state.
---@param bufnr integer
---@param source string
local function set_buffer_source(bufnr, source)
  local has_eol = vim.endswith(source, '\n')
  local lines = vim.split(source, '\n', { plain = true })
  if has_eol then
    table.remove(lines)
  end
  if #lines == 0 then
    lines = { '' }
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].endofline = has_eol
  vim.bo[bufnr].modified = false
end

---Create or focus an editable TypeScript buffer for a user script.
---@param script Lichtblick.Script
function M.open(script)
  local origin = script.layout_path
    or table.concat({ script.indexeddb.database, script.indexeddb.namespace, script.indexeddb.id }, '\0')
  local key = origin .. '\0' .. script.id
  local existing = open_buffers[key]
  if existing and vim.api.nvim_buf_is_valid(existing) then
    vim.api.nvim_win_set_buf(0, existing)
    return
  end

  local project_dir, project_err = project.ensure(script)
  if not project_dir then
    notify(project_err, vim.log.levels.ERROR)
    return
  end

  local bufnr = vim.api.nvim_create_buf(true, false)
  local safe_name = script.name:gsub('[^%w_.-]', '_')
  local script_name = ('%s-%s.ts'):format(safe_name, script.id:sub(1, 8))
  vim.api.nvim_buf_set_name(bufnr, project_dir .. '/' .. script_name)
  vim.bo[bufnr].buftype = 'acwrite'
  vim.bo[bufnr].bufhidden = 'hide'
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = 'typescript'
  if script.layout_path then
    vim.b[bufnr].lichtblick_layout_path = script.layout_path
  end
  vim.b[bufnr].lichtblick_script_id = script.id
  set_buffer_source(bufnr, script.source_code)

  open_buffers[key] = bufnr
  vim.api.nvim_create_autocmd('BufWriteCmd', {
    buffer = bufnr,
    callback = function() save_script(bufnr, script) end,
    desc = 'Save Lichtblick user script to its layout',
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = bufnr,
    callback = function() open_buffers[key] = nil end,
    once = true,
    desc = 'Forget Lichtblick user script buffer',
  })
  vim.api.nvim_win_set_buf(0, bufnr)
  project.start_lsp(bufnr)
end

return M
