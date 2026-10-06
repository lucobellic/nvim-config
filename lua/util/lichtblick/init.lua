local config = require('util.lichtblick.config')
local editor = require('util.lichtblick.editor')
local indexeddb = require('util.lichtblick.indexeddb')
local layout = require('util.lichtblick.layout')

---@class Lichtblick.Selection
---@field layout Lichtblick.Layout
---@field script? Lichtblick.Script

---@class Lichtblick.Module
---@field open fun() Select a script or create one in an empty layout.
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

---@param selected_layout Lichtblick.Layout
---@return string|nil
local function layout_key(selected_layout)
  local metadata = selected_layout.indexeddb
  if metadata then
    return table.concat({ metadata.database, metadata.namespace, metadata.id }, '\0')
  end
end

---@param selected_layout Lichtblick.Layout
local function create_script(selected_layout)
  vim.ui.input(
    { prompt = 'New Lichtblick script name: ' },
    ---@param name string|nil
    function(name)
      if not name then
        return
      end
      name = vim.trim(name)
      if name == '' then
        notify('Script name cannot be empty', vim.log.levels.WARN)
        return
      end

      local identifier = vim.fn.sha256(selected_layout.layout_name .. name .. tostring(vim.uv.hrtime()))
      ---@type Lichtblick.Script
      local script = vim.tbl_extend('force', selected_layout, {
        id = ('%s-%s-4%s-8%s-%s'):format(
          identifier:sub(1, 8),
          identifier:sub(9, 12),
          identifier:sub(14, 16),
          identifier:sub(18, 20),
          identifier:sub(21, 32)
        ),
        name = name,
        source_code = '',
        is_new = true,
      })
      editor.open(script)
    end
  )
end

---Select a user script or an empty layout from local files or Lichtblick IndexedDB.
---@public
function M.open()
  local scripts, local_err, invalid_count, local_empty_layouts = layout.discover_scripts(config.layout_dir)
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

  local database_scripts, database_err, database_empty_layouts = indexeddb.discover_scripts()
  if database_scripts then
    for _, script in ipairs(database_scripts) do
      if not linked_scripts[database_key(script)] and not local_scripts[display_key(script)] then
        table.insert(scripts, script)
      end
    end
  else
    notify(database_err, vim.log.levels.WARN)
  end
  ---@type Lichtblick.Selection[]
  local selections = {}
  ---@type table<string, boolean>
  local linked_layouts = {}
  ---@type table<string, boolean>
  local layout_names = {}
  ---@param selected_layout Lichtblick.Layout
  local function remember_layout(selected_layout)
    layout_names[selected_layout.layout_name] = true
    local key = layout_key(selected_layout)
    if key then
      linked_layouts[key] = true
    end
  end
  vim.iter(scripts):each(
    ---@param script Lichtblick.Script
    function(script)
      table.insert(selections, { layout = script, script = script })
      remember_layout(script)
    end
  )
  vim.iter({ local_empty_layouts or {}, database_empty_layouts or {} }):each(
    ---@param empty_layouts Lichtblick.Layout[]
    function(empty_layouts)
      vim.iter(empty_layouts):each(
        ---@param empty_layout Lichtblick.Layout
        function(empty_layout)
          local key = layout_key(empty_layout)
          if not (key and linked_layouts[key]) and not layout_names[empty_layout.layout_name] then
            table.insert(selections, { layout = empty_layout })
            remember_layout(empty_layout)
          end
        end
      )
    end
  )
  table.sort(
    selections,
    ---@param left Lichtblick.Selection
    ---@param right Lichtblick.Selection
    ---@return boolean
    function(left, right)
      if left.layout.layout_name == right.layout.layout_name then
        return (left.script and left.script.name or '') < (right.script and right.script.name or '')
      end
      return left.layout.layout_name < right.layout.layout_name
    end
  )

  if #selections == 0 then
    notify('No Lichtblick layouts or user scripts found', vim.log.levels.WARN)
    return
  end
  vim.ui.select(
    selections,
    {
      prompt = 'Lichtblick layout / user script',
      ---@param selection Lichtblick.Selection
      ---@return string
      format_item = function(selection)
        return ('%s  %s'):format(
          selection.layout.layout_name,
          selection.script and selection.script.name or '[New script]'
        )
      end,
    },
    ---@param selection Lichtblick.Selection|nil
    function(selection)
      if selection then
        if selection.script then
          editor.open(selection.script)
        else
          create_script(selection.layout)
        end
      end
    end
  )
end

---@param opts? Lichtblick.Config
---@public
function M.setup(opts)
  config.setup(opts)
  if vim.fn.exists(':LichtblickExtractLayout') == 2 then
    vim.api.nvim_del_user_command('LichtblickExtractLayout')
  end
  vim.api.nvim_create_user_command('LichtblickOpenUserScript', M.open, {
    desc = 'Open a Lichtblick user script or create one in an empty layout',
    force = true,
  })
end

return M
