return {
  'folke/twilight.nvim',
  opts = {
    dimming = {
      alpha = 0.25,
      inactive = true,
    },
  },
  cmd = { 'Twilight' },
  keys = {
    { '<A-z>', '<cmd>Twilight<cr>', desc = 'Twilight' },
    { '<leader>za', '<cmd>Twilight<cr>', desc = 'Twilight' },
  },
}
