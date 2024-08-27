return {
  'neovim/nvim-lspconfig',
  event = 'LazyFile',
  dependencies = {
    {
      'williamboman/mason-lspconfig.nvim',
      dependencies = {
        'williamboman/mason.nvim',
        cmd = 'Mason',
        opts = {
          PATH = 'prepend',
          ui = {
            border = vim.g.border.style,
            width = 0.8,
            height = 0.8,
          },
        },
      },
      opts = {
        ensure_installed = {
          'jsonls',
          'vimls',
          'neocmake',
          'lua_ls',
        },
        automatic_installation = false,
      },
    },
  },
  opts = function(_, opts)
    opts.codelens = { enabled = false }
    opts.inlay_hints = { enabled = false }

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
      tsserver = require('plugins.lsp.util.servers.tsserver'),
      lua_ls = require('plugins.lsp.util.servers.lua_ls'),
      ansiblels = {},
    })

    opts.diagnostics = vim.tbl_deep_extend('force', opts.diagnostics or {}, {
      virtual_text = false,
      virtual_lines = false,
      signs = {
        --  ┊ ┆ ╎
        text = {
          [vim.diagnostic.severity.ERROR] = '┊',
          [vim.diagnostic.severity.WARN] = '┊',
          [vim.diagnostic.severity.INFO] = '┊',
          [vim.diagnostic.severity.HINT] = '┊',
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
          [vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
          [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
          [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { source = true, header = {}, border = vim.g.border.style },
    })


    require('lspconfig.ui.windows').default_options.border = vim.g.border.style
    require('plugins.lsp.util.keymaps').setup()
    return opts
  end,
}
