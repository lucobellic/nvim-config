local nvim_lsp = require('lspconfig')
local util = require('plugins.lsp.config.util')

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { 'rust_analyzer', 'jsonls', 'vimls', 'cmake' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = util.on_attach,
    capabilities = util.capabilities
  }
end

nvim_lsp.lua_ls.setup({
  on_attach = util.on_attach,
  capabilities = util.capabilities,
  settings = {
    Lua = {
      format = {
        enable = true,
        defaultConfig = {
          indent_style = 'space',
          indent_size = '2',
          column_width = '120'
        }
      },
      completion = {
        callSnippet = 'Replace'
      },
      telemetry = {
        enable = false,
      },
      diagnostic = {
        enable = true,
        neededFileStatus = {
          ['codestyle-check'] = 'Any'
        }
      },
    }
  }
})

nvim_lsp.pylsp.setup {
  on_attach = util.on_attach,
  capabilities = util.capabilities,
  -- configurationSources = { 'flake8', 'pycodestyle' },
  settings = {
    pylsp = {
      configurationSources = { 'flake8', 'pycodestyle' },
      plugins = {
        rope_completion = {
          enabled = true
        },
        flake8 = {
          enabled = true
        },
        pylint = {
          enabled = false
        },
        pydocstyle = {
          enabled = false
        },
        pycodestyle = {
          maxLineLength = 100,
          enabled = true
        }
      }
    }
  }
}

-- C/C++ Clangd configuration
-- local nvim_lsp_clangd_highlight = require('nvim-lsp-clangd-highlight')
nvim_lsp.clangd.setup {
  -- on_init = nvim_lsp_clangd_highlight.on_init,
  on_attach = util.on_attach,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--enable-config",
    "--header-insertion=iwyu",
    "--all-scopes-completion",
    "--offset-encoding=utf-16",
    "-j=2",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  settings = {
    semanticHighlighting = true
  },
  capabilities = util.capabilities
}

-- TODO: set it in clangd.setup
vim.cmd [[map <silent> <M-o> :ClangdSwitchSourceHeader <CR>]]
