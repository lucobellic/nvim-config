local config = require('util.lichtblick.config')
local file = require('util.lichtblick.file')

---@class Lichtblick.ProjectModule
---@field ensure fun(script: Lichtblick.Script): string|nil, string|nil Prepare a TypeScript project for a script.
---@field start_lsp fun(bufnr: integer) Start TypeScript LSP for a script buffer.
---@type Lichtblick.ProjectModule
local M = {}

---@param message string
---@param level? integer
local function notify(message, level) vim.notify(message, level or vim.log.levels.INFO, { title = 'Lichtblick' }) end

---Return the installed Lichtblick package version when available.
---@return string
local function installed_lichtblick_version()
  if vim.fn.executable('dpkg-query') ~= 1 then
    return 'latest'
  end

  local result = vim.system({ 'dpkg-query', '-W', '-f=${Version}', 'lichtblick' }, { text = true }):wait()
  if result.code ~= 0 then
    return 'latest'
  end
  return vim.trim(result.stdout):match('^%d+%.%d+%.%d+') or 'latest'
end

---Create package metadata and install the TypeScript dependencies when needed.
---@return boolean success
---@return string|nil error
local function ensure_dependencies()
  local package_path = config.project_dir .. '/package.json'
  local dependencies = {
    ['@foxglove/schemas'] = config.foxglove_schemas_version,
    ['@lichtblick/suite'] = installed_lichtblick_version(),
  }
  local package_content = vim.json.encode({
    private = true,
    dependencies = dependencies,
  })
  local current_package = file.read(package_path)
  local decode_ok, current_config = pcall(vim.json.decode, current_package or '')
  local package_changed = not decode_ok
    or type(current_config.dependencies) ~= 'table'
    or current_config.dependencies['@lichtblick/suite'] ~= dependencies['@lichtblick/suite']
    or current_config.dependencies['@foxglove/schemas'] ~= dependencies['@foxglove/schemas']
  local needs_install = package_changed
    or vim.fn.filereadable(config.project_dir .. '/node_modules/@lichtblick/suite/package.json') ~= 1
    or vim.fn.filereadable(config.project_dir .. '/node_modules/@foxglove/schemas/package.json') ~= 1

  if package_changed then
    local ok, write_err = file.write(package_path, package_content)
    if not ok then
      return false, ('Cannot write package.json: %s'):format(write_err)
    end
  end
  if not needs_install then
    return true
  end
  if vim.fn.executable('yarn') ~= 1 then
    return false, 'Yarn is required to install Lichtblick TypeScript definitions'
  end

  notify('Installing Lichtblick TypeScript definitions with Yarn...')
  local result = vim
    .system({ 'yarn', 'install', '--non-interactive', '--silent' }, {
      cwd = config.project_dir,
      text = true,
    })
    :wait()
  if result.code ~= 0 then
    return false, ('Yarn failed to install Lichtblick definitions: %s'):format(result.stderr)
  end
  return true
end

---Prepare generated TypeScript support files for a user script.
---@param script Lichtblick.Script
---@return string|nil project_dir
---@return string|nil error
function M.ensure(script)
  if vim.fn.mkdir(config.project_dir, 'p') == 0 and vim.fn.isdirectory(config.project_dir) ~= 1 then
    return nil, ('Cannot create TypeScript project: %s'):format(config.project_dir)
  end

  local template_dir = vim.fn.stdpath('config') .. '/lua/util/lichtblick/project'
  local tsconfig, read_err = file.read(template_dir .. '/tsconfig.json')
  if not tsconfig then
    return nil, ('Cannot read tsconfig.json template: %s'):format(read_err)
  end

  local ok, write_err = file.write(config.project_dir .. '/tsconfig.json', tsconfig)
  if not ok then
    return nil, ('Cannot write tsconfig.json: %s'):format(write_err)
  end

  local dependencies_ok, dependencies_err = ensure_dependencies()
  if not dependencies_ok then
    return nil, dependencies_err
  end

  local project_key = script.layout_path
    or table.concat({ script.indexeddb.database, script.indexeddb.namespace, script.indexeddb.id }, '\0')
  local script_dir = config.project_dir .. '/' .. vim.fn.sha256(project_key):sub(1, 12)
  if vim.fn.mkdir(script_dir, 'p') == 0 and vim.fn.isdirectory(script_dir) ~= 1 then
    return nil, ('Cannot create script directory: %s'):format(script_dir)
  end
  vim.uv.fs_unlink(script_dir .. '/generatedTypes.ts')
  vim.uv.fs_unlink(script_dir .. '/tsconfig.json')

  local types_content, types_read_err = file.read(template_dir .. '/types.ts')
  if not types_content then
    return nil, ('Cannot read types.ts template: %s'):format(types_read_err)
  end
  local types_ok, types_err = file.write(script_dir .. '/types.ts', types_content)
  if not types_ok then
    return nil, ('Cannot write types.ts: %s'):format(types_err)
  end

  return script_dir
end

---Start tsgo using the shared Lichtblick project as its root.
---@param bufnr integer
function M.start_lsp(bufnr)
  local ok, lazy = pcall(require, 'lazy')
  if ok then
    lazy.load({ plugins = { 'nvim-lspconfig' } })
  end

  local tsgo = vim.lsp.config.tsgo
  if tsgo and vim.fn.executable('tsgo') == 1 then
    vim.lsp.start(vim.tbl_deep_extend('force', tsgo, { root_dir = config.project_dir }), { bufnr = bufnr })
  end
end

return M
