return {
  "neovim/nvim-lspconfig",
  opts = {
    -- Automatically format on save
    autoformat = false,
    -- Enable nvim-ufo capabilities
    capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
    inlay_hints = {
      enabled = true,
    },
    servers = {
      clangd = require('util.lsp.servers.clangd'),
      pylsp = require('util.lsp.servers.pylsp'),
      lua_ls = {
        Lua = {
          workspace = {
            checkThirdParty = true,
          },
        },
      },
    },
    diagnostics = {
      virtual_text = false,
      virtual_lines = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { source = true, header = {} },
    },
  },
  init = require("util.lsp.keymaps"),
}
