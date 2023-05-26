local nvim_lsp = require('lspconfig')
local util = require('plugins.lsp.config.util')

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { 'rust_analyzer', 'jsonls', 'vimls', 'cmake', 'yamlls' }
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
