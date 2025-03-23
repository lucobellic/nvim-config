return {
  'olimorris/VectorCode',
  version = '*',
  enabled = vim.fn.executable('pipx') == 1 and not vim.g.neovide,
  build = 'pipx upgrade vectorcode', -- optional but recommended if you set `version = "*"`
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    async_backend = 'lsp',
  },
}
