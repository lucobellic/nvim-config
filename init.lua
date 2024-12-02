-- Set border style
local enable_border = true -- not vim.g.neovide
vim.g.border = {
  enabled = enable_border,
  style = enable_border and 'rounded' or { ' ' },
  borderchars = enable_border and { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
    or { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
}

if vim.env.PROF then
  local snacks = vim.fn.stdpath('data') .. '/lazy/snacks.nvim'
  vim.opt.rtp:append(snacks)
  require('snacks.profiler').startup({
    startup = {
      event = 'VimEnter', -- stop profiler on this event. Defaults to `VimEnter`
      -- event = "UIEnter",
      -- event = "VeryLazy",
    },
    pick = {
      picker = 'telescope',
    },
  })
end

require('config')
