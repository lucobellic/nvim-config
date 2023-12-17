return {
  'hedyhli/outline.nvim',
  lazy = true,
  cmd = { 'Outline', 'OutlineOpen' },
  keys = {
    { '<leader>go', '<cmd>Outline<CR>', desc = 'Toggle outline' },
  },
  opts = true,
}
