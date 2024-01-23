return {
  'neovim/nvim-lspconfig',
  opts = function(_, opts)
    -- Automatically format on save
    opts.inlay_hints = { enabled = true }

    -- Enable nvim-ufo capabilities
    opts.capabilities = vim.tbl_deep_extend('force', opts.capabilities or {}, {
      textDocument = {
        foldingRange = {
          dynamicRegistration = true,
          lineFoldingOnly = true,
        },
      },
    })

    opts.servers = vim.tbl_deep_extend('force', opts.servers or {}, {
      clangd = require('plugins.lsp.util.servers.clangd'),
      tsserver = {
        single_file_support = false,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'literal',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            hint = {
              enable = true,
              setType = true,
              arrayIndex = 'Disable',
            },
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
      pylsp = require('plugins.lsp.util.servers.pylsp'),
      ruff_lsp = {},
      ansiblels = {},
    })

    opts.servers.pyright = nil

    opts.diagnostics = vim.tbl_deep_extend('force', opts.diagnostics or {}, {
      virtual_text = false,
      virtual_lines = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { source = true, header = {} },
    })

    require('lspconfig.ui.windows').default_options.border = 'rounded'
  end,
  init = require('plugins.lsp.util.keymaps'),
}
