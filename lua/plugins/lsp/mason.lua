return {
  'williamboman/mason-lspconfig.nvim',
  dependencies = {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {
      PATH = 'prepend',
      ui = {
        border = vim.g.border,
        width = 0.8,
        height = 0.8,
      },
    },
  },
  event = 'VeryLazy',
  opts = {
    ensure_installed = {
      'jsonls',
      'vimls',
      'cmake',
      'lua_ls',
      'rust_analyzer',
    },
    automatic_installation = false,
  },
}
