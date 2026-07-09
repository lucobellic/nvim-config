return {
  'kevinhwang91/nvim-fundo',
  lazy = false, -- must load before BufReadPost to re-sync undo files on open
  dependencies = { 'kevinhwang91/promise-async' },
  opts = {},
}
