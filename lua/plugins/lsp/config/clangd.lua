-- C/C++ Clangd configuration
local util = require('plugins.lsp.config.util')
local Path = require('plenary.path')

local cmd_output = vim.fn.systemlist('clangd --version')
local clangd_version = string.match(cmd_output[2], "version (%d+)") or '13'
vim.print("Using clangd version: " .. clangd_version)

local clangd_args = {
  ['16'] = {
    "--background-index",
    "--background-index-priority=background",
    "--clang-tidy",
    "--enable-config",
    "--header-insertion=iwyu",
    "--all-scopes-completion",
    "-j 2",
  },
  ['13'] = {
    "--background-index",
    "--clang-tidy",
    "--enable-config",
    "--header-insertion=iwyu",
    "--all-scopes-completion",
    "-j=2",
  }
}

local mason_clangd_path = Path:new(vim.fn.stdpath('data')):joinpath('mason', 'bin', 'clangd'):absolute()
local clangd_capabilities = vim.tbl_extend('force',
  util.capabilities,
  {
    offsetEncoding = { "utf-16" },
    textDocument = {
      completion = {
        editsNearCursor = true }
    }
  }
)

require('clangd_extensions').setup({
  server = {
    on_attach = util.on_attach,
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    settings = {
      arguments = clangd_args[clangd_version],
      semanticHighlighting = true
    },
    capabilities = clangd_capabilities
  }
})

-- TODO: set it in clangd.setup
vim.cmd [[map <silent> <M-o> :ClangdSwitchSourceHeader <CR>]]
