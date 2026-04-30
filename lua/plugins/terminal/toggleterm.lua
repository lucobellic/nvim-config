return {
  'akinsho/toggleterm.nvim',
  enabled = false,
  cmd = { 'ToggleTerm', 'ToggleTermToggleAll' },
  keys = {
    { '<leader>uP', '<cmd>ToggleTermToggleAll<cr>', desc = 'Toggle All Toggleterm' },
    { '<leader>up', '<cmd>ToggleTerm<cr>', desc = 'Toggle Toggleterm' },
  },
  opts = {},
}
