return {
  dir = vim.fn.stdpath('config') .. '/local/undo-keep',
  name = 'undo-keep',
  main = 'undo-keep',
  lazy = false, -- Must restore history before the first file is opened.
  opts = {},
}
