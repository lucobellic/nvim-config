return {
  'williamboman/mason-lspconfig.nvim',
  opts = {
    ensure_installed = {
      'jsonls',
      'vimls',
      'cmake',
      'lua_ls',
      'rust_analyzer',
      'clangd',
    },
    automatic_installation = false,
  }
}
