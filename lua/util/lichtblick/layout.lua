local file = require('util.lichtblick.file')

---@class Lichtblick.IndexedDBMetadata
---@field database string IndexedDB database name.
---@field namespace string IndexedDB object-store namespace.
---@field id string Layout identifier.

---@class Lichtblick.Layout
---@field indexeddb? Lichtblick.IndexedDBMetadata IndexedDB origin for synchronized scripts.
---@field layout_name string Display name of the containing layout.
---@field layout_path? string Path of the local layout JSON file.

---@class Lichtblick.Script: Lichtblick.Layout
---@field id string User script identifier.
---@field is_new? boolean Create the script on its first save.
---@field name string User script name.
---@field source_code string TypeScript source code.

---@class Lichtblick.LayoutModule
---@field discover_scripts fun(layout_dir: string): Lichtblick.Script[]|nil, string|nil, integer|nil, Lichtblick.Layout[]|nil Discover scripts and empty layouts.
---@field save_script fun(script: Lichtblick.Script, source: string): boolean, string|nil Save a script to its local layout.
---@type Lichtblick.LayoutModule
local M = {}

---Read and decode a layout JSON file.
---@param path string
---@return table|nil layout
---@return string|nil content
---@return string|nil error
local function decode(path)
  local content, read_err = file.read(path)
  if not content then
    return nil, nil, read_err
  end

  local ok, layout = pcall(vim.json.decode, content)
  if not ok or type(layout) ~= 'table' then
    return nil, content, ok and 'JSON root is not an object' or layout
  end
  return layout, content
end

---Read optional IndexedDB synchronization metadata for a layout.
---@param path string
---@return Lichtblick.IndexedDBMetadata|nil
local function indexeddb_metadata(path)
  local content = file.read(path .. '.lichtblick-indexeddb')
  if not content then
    return nil
  end

  local ok, metadata = pcall(vim.json.decode, content)
  if
    not ok
    or type(metadata) ~= 'table'
    or type(metadata.database) ~= 'string'
    or type(metadata.namespace) ~= 'string'
    or type(metadata.id) ~= 'string'
  then
    return nil
  end
  return metadata
end

---Discover valid user scripts from every layout JSON file.
---@param layout_dir string
---@return Lichtblick.Script[]|nil scripts
---@return string|nil error
---@return integer|nil invalid_count Number of invalid JSON files skipped.
---@return Lichtblick.Layout[]|nil empty_layouts
---@public
function M.discover_scripts(layout_dir)
  local stat = vim.uv.fs_stat(layout_dir)
  if not stat or stat.type ~= 'directory' then
    return nil, ('Layout directory does not exist: %s'):format(layout_dir)
  end

  local files = vim.fs.find(function(name) return vim.endswith(name, '.json') end, {
    path = layout_dir,
    type = 'file',
    limit = math.huge,
  })
  local scripts = {}
  local empty_layouts = {}
  local invalid_count = 0

  for _, path in ipairs(files) do
    local layout, _, err = decode(path)
    if err then
      invalid_count = invalid_count + 1
    else
      local database = indexeddb_metadata(path)
      local script_count = #scripts
      for script_id, script in pairs(type(layout.userNodes) == 'table' and layout.userNodes or {}) do
        if
          type(script_id) == 'string'
          and type(script) == 'table'
          and type(script.name) == 'string'
          and type(script.sourceCode) == 'string'
        then
          table.insert(scripts, {
            id = script_id,
            indexeddb = database,
            layout_path = path,
            layout_name = vim.fn.fnamemodify(path, ':t:r'),
            name = script.name,
            source_code = script.sourceCode,
          })
        end
      end
      if #scripts == script_count then
        table.insert(empty_layouts, {
          indexeddb = database,
          layout_path = path,
          layout_name = vim.fn.fnamemodify(path, ':t:r'),
        })
      end
    end
  end

  table.sort(scripts, function(left, right)
    if left.layout_path == right.layout_path then
      return left.name < right.name
    end
    return left.layout_path < right.layout_path
  end)

  return scripts, nil, invalid_count, empty_layouts
end

---Create or update a user script in its local layout file.
---@param script Lichtblick.Script
---@param source string
---@return boolean success
---@return string|nil error
---@public
function M.save_script(script, source)
  local layout, content, err = decode(script.layout_path)
  if not layout then
    return false, ('Cannot read %s: %s'):format(script.layout_path, err)
  end

  local stored_script = type(layout.userNodes) == 'table' and layout.userNodes[script.id] or nil
  if
    not (script.is_new and stored_script == nil)
    and (type(stored_script) ~= 'table' or type(stored_script.sourceCode) ~= 'string')
  then
    return false, ('Script %q no longer exists in %s'):format(script.name, script.layout_path)
  end

  local source_path = vim.fn.tempname()
  local source_ok, source_err = file.write(source_path, source)
  if not source_ok then
    return false, ('Cannot create temporary source file: %s'):format(source_err)
  end

  local result = vim
    .system({
      'jq',
      '--indent',
      '2',
      '--arg',
      'script_id',
      script.id,
      '--rawfile',
      'source',
      source_path,
      '--arg',
      'name',
      script.name,
      script.is_new
          and '.userNodes //= {} | .userNodes[$script_id] //= {name: $name} | .userNodes[$script_id].sourceCode = $source'
        or '.userNodes[$script_id].sourceCode = $source',
    }, { stdin = content, text = true })
    :wait()
  vim.uv.fs_unlink(source_path)

  if result.code ~= 0 then
    return false, ('Cannot update %s: %s'):format(script.layout_path, result.stderr)
  end

  local write_ok, write_err = file.atomic_write(script.layout_path, result.stdout)
  if not write_ok then
    return false, ('Cannot write %s: %s'):format(script.layout_path, write_err)
  end
  return true
end

return M
