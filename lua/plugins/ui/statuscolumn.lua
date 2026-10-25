return {
  dir = vim.fn.stdpath('config') .. '/local/statuscolumn',
  name = 'statuscolumn',
  lazy = false,
  config = function() require('statuscolumn').setup() end,
}
