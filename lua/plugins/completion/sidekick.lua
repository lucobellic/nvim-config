return {
  'folke/sidekick.nvim',
  event = 'BufEnter',
  cond = not vim.env.INSIDE_DOCKER,
  opts = {},
}
