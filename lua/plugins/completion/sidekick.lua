return {
  'folke/sidekick.nvim',
  event = 'BufEnter',
  cond = not vim.env.INSIDE_DOCKER,
  opts = {},
  config = function(_, opts)
    require('sidekick').setup(opts)
  end,
}


