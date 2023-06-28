-- C/C++ Clangd configuration
local nvim_lsp = require('lspconfig')
local util = require('plugins.lsp.config.util')
local Path = require('plenary.path')

local cmd_output = vim.fn.systemlist('clangd --version')
local clangd_version = string.match(cmd_output[2], "version (%d+)") or '13'

local clangd_args = {
  ['16'] = {
    "--background-index",
    "--background-index-priority=background",
    "--all-scopes-completion",
    "--pch-storage=memory",
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
      inlayHints = { enabled = true },
      completion = { editsNearCursor = true }
    }
  }
)

nvim_lsp.clangd.setup({
  cmd = { mason_clangd_path }, -- { '/usr/bin/clangd' },
  on_attach = util.on_attach,
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  capabilities = clangd_capabilities,
  settings = {
    arguments = clangd_args[clangd_version],
    semanticHighlighting = true,
  },
})

-- TODO: set it in clangd.setup
vim.cmd [[map <silent> <M-o> :ClangdSwitchSourceHeader <CR>]]
