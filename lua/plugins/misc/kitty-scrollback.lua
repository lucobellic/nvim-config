return {
  'mikesmithgh/kitty-scrollback.nvim',
  cond = vim.env.TERM and vim.env.TERM:find('kitty') and vim.env.KITTY_SCROLLBACK_NVIM == 'true',
  cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
  event = { 'User KittyScrollbackLaunch' },
  opts = {
    {
      paste_window = { yank_register_enabled = false },
    },
  },
}
