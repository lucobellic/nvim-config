return {
  'olimorris/VectorCode',
  version = '*',
  build = 'pipx upgrade vectorcode', -- optional but recommended if you set `version = "*"`
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    async_backend = 'lsp',
  },
}
