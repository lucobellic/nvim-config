return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Automatically format on save
    opts.autoformat = false
    opts.inlay_hints = { enabled = true }

    -- Enable nvim-ufo capabilities
    opts.capabilities = vim.tbl_deep_extend('force', opts.capabilities or {}, {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    })

    opts.servers = vim.tbl_deep_extend('force', opts.servers or {}, {
      clangd = require('util.lsp.servers.clangd'),
      lua_ls = {
        Lua = {
          workspace = {
            checkThirdParty = true,
          },
        },
      },
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
  end,
  init = require("util.lsp.keymaps"),
}
