-- Set border style
local enable_border = true -- not vim.g.neovide
vim.g.border = {
  enabled = enable_border,
  style = enable_border and 'rounded' or { ' ' },
  borderchars = enable_border and { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
    or { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
}

require('config')
