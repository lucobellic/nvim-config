---@class Lichtblick.Config
---@field layout_dir string Directory containing saved layout JSON files.
---@field project_dir string Directory used for generated TypeScript projects and backups.
---@field foxglove_schemas_version string Version of `@foxglove/schemas` to install.
---@field debug_port integer Local Chrome DevTools Protocol port.
---@field debug_start_timeout integer Milliseconds to wait for the debug endpoint.
---@field lichtblick_executable string Executable used to launch Lichtblick.
---@field auto_start_debug boolean Whether to relaunch Lichtblick with remote debugging.

---@class Lichtblick.ConfigModule: Lichtblick.Config
---@field setup fun(opts?: Lichtblick.Config) Configure the Lichtblick integration.
---@type Lichtblick.ConfigModule
local M = {
  layout_dir = vim.fn.expand('~/.lichtblick-suite/layouts'),
  project_dir = vim.fn.stdpath('cache') .. '/lichtblick',
  foxglove_schemas_version = '1.9.0',
  debug_port = 9222,
  debug_start_timeout = 15000,
  lichtblick_executable = 'lichtblick',
  auto_start_debug = true,
}

---Configure Lichtblick paths, dependencies, and debugging behavior.
---@param opts? Lichtblick.Config User configuration overrides.
function M.setup(opts)
  local config = vim.tbl_deep_extend('force', M, opts or {})
  config.layout_dir = vim.fs.normalize(vim.fn.expand(config.layout_dir))
  config.project_dir = vim.fs.normalize(vim.fn.expand(config.project_dir))

  for key, value in pairs(config) do
    if key ~= 'setup' then
      M[key] = value
    end
  end
end

return M
