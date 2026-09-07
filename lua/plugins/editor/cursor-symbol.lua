return {
  dir = vim.fn.stdpath('config') .. '/local/cursor-symbol',
  name = 'cursor-symbol',
  lazy = false,
  keys = {
    {
      '<leader>uc',
      function() require('cursor-symbol').toggle() end,
      repeatable = true,
      desc = 'Toggle word highlight under cursor',
    },
  },
  opts = {},
}
