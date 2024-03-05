return {
  'williamboman/mason.nvim',
  dependencies = {
    {
      'williamboman/mason-lspconfig.nvim',
      event = 'VeryLazy',
      opts = {
        ensure_installed = {
          'jsonls',
          'vimls',
          'cmake',
          'lua_ls',
          'rust_analyzer',
          'clangd',
          'cspell',
        },
        automatic_installation = false,
      },
    },
  },
  cmd = 'Mason',
  opts = {
    PATH = 'prepend',
    ui = {
      border = 'rounded',
      width = 0.8,
      height = 0.8,
    },
  },
}
