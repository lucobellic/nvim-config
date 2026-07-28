local config = require('util.lichtblick.config')
local editor = require('util.lichtblick.editor')
local indexeddb = require('util.lichtblick.indexeddb')
local layout = require('util.lichtblick.layout')

---@class Lichtblick.Module
---@field open fun() Select and open a discovered Lichtblick user script.
---@field setup fun(opts?: Lichtblick.Config) Configure commands and integration settings.
---@type Lichtblick.Module
local M = {}

---@param message string
---@param level? integer
local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Lichtblick' }) end

---@param script Lichtblick.Script
---@return string|nil
local function database_key(script)
  if not script.indexeddb then
    return nil
  end
  return table.concat({ script.indexeddb.database, script.indexeddb.namespace, script.indexeddb.id, script.id }, '\0')
end

---@param script Lichtblick.Script
---@return string
local function display_key(script) return script.layout_name .. '\0' .. script.name end

---Select a user script discovered from local layouts or Lichtblick IndexedDB.
function M.open()
  local scripts, local_err, invalid_count = layout.discover_scripts(config.layout_dir)
  if not scripts then
    scripts = {}
    notify(local_err, vim.log.levels.WARN)
  end
  if invalid_count and invalid_count > 0 then
    notify(('Skipped %d invalid JSON file(s)'):format(invalid_count), vim.log.levels.WARN)
  end

  local linked_scripts = {}
  local local_scripts = {}
  for _, script in ipairs(scripts) do
    local_scripts[display_key(script)] = true
    local key = database_key(script)
    if key then
      linked_scripts[key] = true
    end
  end

  local database_scripts, database_err = indexeddb.discover_scripts()
  if database_scripts then
    for _, script in ipairs(database_scripts) do
      if not linked_scripts[database_key(script)] and not local_scripts[display_key(script)] then
        table.insert(scripts, script)
      end
    end
  else
    notify(database_err, vim.log.levels.WARN)
  end
  table.sort(scripts, function(left, right)
    if left.layout_name == right.layout_name then
      return left.name < right.name
    end
    return left.layout_name < right.layout_name
  end)

  if #scripts == 0 then
    notify('No Lichtblick user scripts found', vim.log.levels.WARN)
    return
  end
  vim.ui.select(scripts, {
    prompt = 'Lichtblick user script',
    format_item = function(script) return ('%s  %s'):format(script.layout_name, script.name) end,
  }, function(script)
    if script then
      editor.open(script)
    end
  end)
end

---@param opts? Lichtblick.Config
function M.setup(opts)
  config.setup(opts)
  if vim.fn.exists(':LichtblickExtractLayout') == 2 then
    vim.api.nvim_del_user_command('LichtblickExtractLayout')
  end
  vim.api.nvim_create_user_command('LichtblickOpenUserScript', M.open, {
    desc = 'Open a Lichtblick user script',
    force = true,
  })
end

return M
