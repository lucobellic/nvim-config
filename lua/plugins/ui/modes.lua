return {
  'mvllow/modes.nvim',
  cond = false, -- Options and highlights are not respected
  version = '*',
  event = 'VeryLazy',
  opts = {
    ignore = function() return false end,
  },
}
