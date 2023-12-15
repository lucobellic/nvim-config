return {
  'karb94/neoscroll.nvim',
  event = 'VeryLazy',
  enabled = not vim.g.neovide,
  config = function() require('neoscroll').setup({}) end,
}
