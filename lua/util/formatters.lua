---@class FormatterUtil
local M = {}

---@type table<string, string>
M.packages = {
  ['biome-check'] = 'biome',
  clang_format = 'clang-format',
  goimports = 'goimports',
  ['markdown-toc'] = 'markdown-toc',
  ['markdownlint-cli2'] = 'markdownlint-cli2',
  nixfmt = 'nixfmt',
  prettier = 'prettier',
  ruff_format = 'ruff',
  shfmt = 'shfmt',
  stylua = 'stylua',
  taplo = 'taplo',
}

---@type table<string, boolean>
local attempted = {}
---@type table<string, boolean>
local pending = {}
local refreshing = false

---@param message string
---@param level integer
local function notify(message, level) vim.notify(message, level, { title = 'Formatters' }) end

---@param package_name string
local function install(package_name)
  local registry = require('mason-registry')
  if not registry.has_package(package_name) then
    notify('Mason package not found: ' .. package_name, vim.log.levels.ERROR)
    return
  end

  local package = registry.get_package(package_name)
  if package:is_installed() or package:is_installing() then
    return
  end

  package:install(
    {},
    vim.schedule_wrap(
      ---@param success boolean
      ---@param result any
      function(success, result)
        if success then
          notify(package_name .. ' is ready for the next format command', vim.log.levels.INFO)
        else
          notify(
            ('Could not install %s: %s\nRetry with :MasonInstall %s'):format(
              package_name,
              tostring(result),
              package_name
            ),
            vim.log.levels.ERROR
          )
        end
      end
    )
  )
end

---@param package_name string
local function request_install(package_name)
  if attempted[package_name] then
    return
  end
  -- LazyVim emits FileType again after installation.
  attempted[package_name] = true
  pending[package_name] = true
  if refreshing then
    return
  end
  refreshing = true

  require('mason-registry').refresh(vim.schedule_wrap(
    ---@param success boolean
    function(success)
      local packages = vim.tbl_keys(pending)
      pending = {}
      refreshing = false
      if not success then
        notify('Could not refresh Mason registry. Run :MasonUpdate and reopen the buffer.', vim.log.levels.ERROR)
        vim.iter(packages):each(
          ---@param name string
          function(name) attempted[name] = nil end
        )
        return
      end
      vim.iter(packages):each(install)
    end
  ))
end

---@param bufnr integer
local function ensure_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= '' then
    return
  end
  local filetype = vim.bo[bufnr].filetype
  if filetype == '' then
    return
  end

  local conform = require('conform')
  local formatters = conform.formatters_by_ft[filetype]
  if type(formatters) == 'function' then
    formatters = formatters(bufnr)
  end
  if not formatters then
    return
  end

  local stop_after_first = formatters.stop_after_first
  vim.iter(ipairs(formatters)):any(
    ---@param _ integer
    ---@param formatter string
    ---@return boolean
    function(_, formatter)
      local info = conform.get_formatter_info(formatter, bufnr)
      if info.available then
        return stop_after_first == true
      end
      local package_name = M.packages[formatter]
      -- A failed condition is not a missing executable.
      if package_name and not info.error and info.command and vim.fn.executable(info.command) == 0 then
        request_install(package_name)
        return stop_after_first == true
      end
      return false
    end
  )
end

---@public
function M.setup()
  require('util.formatters.discovery').setup()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('formatter_install', { clear = true }),
    desc = 'Install missing formatters for the buffer',
    callback = vim.schedule_wrap(
      ---@param event vim.api.keyset.create_autocmd.callback_args
      function(event) ensure_buffer(event.buf) end
    ),
  })
  -- Wait for Conform setup and include buffers opened before the plugin loaded.
  vim.schedule(function() vim.iter(vim.api.nvim_list_bufs()):each(ensure_buffer) end)
end

return M
