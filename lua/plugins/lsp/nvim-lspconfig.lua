return {
  'neovim/nvim-lspconfig',
  opts = function(_, opts)
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
      clangd = require('plugins.lsp.util.servers.clangd'),
      tsserver = require('plugins.lsp.util.servers.tsserver'),
      lua_ls = require('plugins.lsp.util.servers.lua_ls'),
      pylsp = require('plugins.lsp.util.servers.pylsp'),
      ruff_lsp = require('plugins.lsp.util.servers.ruff_lsp'),
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
