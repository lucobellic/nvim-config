if vim.g.vscode then
  require('plugins.lsp.util.keymaps').setup_vscode()
end

return {
  {
    'williamboman/mason.nvim',
    opts = {
      PATH = 'prepend',
      ui = {
        border = vim.g.border.style,
        width = 0.8,
        height = 0.8,
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      opts = vim.tbl_deep_extend('force', opts or {}, {
        codelens = { enabled = false },
        inlay_hints = { enabled = false },
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = true,
              lineFoldingOnly = true,
            },
          },
        },
        diagnostics = {
          virtual_text = false,
          virtual_lines = false,
          signs = {
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
          update_in_insert = true,
          severity_sort = true,
          float = { source = true, header = {}, border = vim.g.border.style },
        },
      })

      require('lspconfig.ui.windows').default_options.border = vim.g.border.style
      require('plugins.lsp.util.keymaps').setup()
      return opts
    end,
  },
}
