---@class FormatterDiscovery
local M = {}

-- Most package names match Conform directly or after replacing dashes with underscores.
---@type table<string, string>
local formatter_aliases = {
  ['brighterscript-formatter'] = 'bsfmt',
  ['clang-format'] = 'clang_format',
  cmakelang = 'cmake_format',
  dcm = 'dcm_format',
  deno = 'deno_fmt',
  ['erb-formatter'] = 'erb_format',
  ['gdscript-formatter'] = 'gdformat',
  gdtoolkit = 'gdformat',
  hclfmt = 'hcl',
  luaformatter = 'lua-format',
  ['nginx-config-formatter'] = 'nginxfmt',
  ['nixpkgs-fmt'] = 'nixpkgs_fmt',
  nomad = 'nomad_fmt',
  opa = 'opa_fmt',
  pgformatter = 'pg_format',
  ['purescript-tidy'] = 'purs-tidy',
  ruff = 'ruff_format',
  terraform = 'terraform_fmt',
  ['vhdl-style-guide'] = 'vsg',
}

-- Mason uses language names rather than Neovim filetypes.
---@type table<string, string[]>
local language_aliases = {
  Angular = { 'htmlangular' },
  Assembly = { 'asm' },
  Bash = { 'sh', 'bash' },
  Bazel = { 'bzl' },
  BrighterScript = { 'brs' },
  ['C#'] = { 'cs' },
  ['C++'] = { 'cpp' },
  ClojureScript = { 'clojure' },
  Django = { 'htmldjango' },
  ['F#'] = { 'fsharp' },
  Flow = { 'javascript', 'javascriptreact' },
  GDScript = { 'gdscript' },
  JSX = { 'javascriptreact' },
  Kerboscript = { 'ksp' },
  Ksh = { 'sh' },
  LaTeX = { 'tex', 'plaintex' },
  Makefile = { 'make' },
  Mksh = { 'sh' },
  ['OCaml-interface'] = { 'ocaml' },
  Octave = { 'matlab' },
  Postgres = { 'sql' },
  Protobuf = { 'proto' },
  ['R Markdown'] = { 'rmd' },
  Shell = { 'sh' },
  SuperHTML = { 'html' },
  TypeScript = { 'typescript', 'typescriptreact' },
  WebAssembly = { 'wat' },
}

---@type table<string, conform.FiletypeFormatterInternal>
local discovered = {}
local listening = false
local scheduled = false

---@param package_name string
---@return string?
local function formatter_name(package_name)
  local formatter_alias = formatter_aliases[package_name]
  local candidates = formatter_alias and { formatter_alias } or { package_name, (package_name:gsub('-', '_')) }
  return vim.iter(candidates):find(
    ---@param name string
    ---@return boolean
    function(name)
      return #vim.api.nvim_get_runtime_file('lua/conform/formatters/' .. name .. '.lua', false) > 0
    end
  )
end

local function refresh()
  local conform = require('conform')
  local registry = require('mason-registry')

  vim.iter(discovered):each(
    ---@param filetype string
    ---@param formatters conform.FiletypeFormatterInternal
    function(filetype, formatters)
      -- Only replace mappings owned by discovery.
      if conform.formatters_by_ft[filetype] == formatters then
        conform.formatters_by_ft[filetype] = nil
      end
    end
  )
  discovered = {}

  local packages = registry.get_installed_package_names()
  -- Stable ordering avoids changing formatter choice between sessions.
  table.sort(packages)
  vim.iter(packages):each(
    ---@param package_name string
    function(package_name)
      local found, package = pcall(registry.get_package, package_name)
      if not found or not vim.tbl_contains(package.spec.categories, 'Formatter') then
        return
      end
      local formatter = formatter_name(package_name)
      if not formatter then
        return
      end

      vim.iter(package.spec.languages):each(
        ---@param language string
        function(language)
          local filetypes = language_aliases[language] or { language:lower() }
          vim.iter(filetypes):each(
            ---@param filetype string
            function(filetype)
              if conform.formatters_by_ft[filetype] ~= nil then
                return
              end
              local formatters = discovered[filetype] or { stop_after_first = true }
              if not vim.tbl_contains(formatters, formatter) then
                table.insert(formatters, formatter)
              end
              discovered[filetype] = formatters
            end
          )
        end
      )
    end
  )

  vim.iter(discovered):each(
    ---@param filetype string
    ---@param formatters conform.FiletypeFormatterInternal
    function(filetype, formatters) conform.formatters_by_ft[filetype] = formatters end
  )
end

local function schedule_refresh()
  if scheduled then
    return
  end
  scheduled = true
  vim.schedule(function()
    scheduled = false
    refresh()
  end)
end

---@public
function M.setup()
  if not listening then
    listening = true
    local registry = require('mason-registry')
    registry:on('package:install:success', schedule_refresh)
    registry:on('package:uninstall:success', schedule_refresh)
    registry:on('update:success', schedule_refresh)
  end
  -- Conform must finish setup before its mappings can be extended.
  schedule_refresh()
end

return M
