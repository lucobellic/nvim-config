-- Set border style
local enable_border = true -- not vim.g.neovide
vim.g.border = {
  enabled = enable_border,
  style = enable_border and 'single' or { ' ' },
  borderchars = enable_border and { '─', '│', '─', '│', '┌', '┐', '┘', '└' }
    or { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
}

if vim.env.PROF then
  local snacks = vim.fn.stdpath('data') .. '/lazy/snacks.nvim'
  vim.opt.rtp:append(snacks)
  ---@diagnostic disable-next-line: missing-fields
  require('snacks.profiler').startup({
    startup = { -- stop profiler on this event. Defaults to `VimEnter`
      -- event = 'VimEnter',
      -- event = "UIEnter",
      event = 'VeryLazy',
    },
    pick = { picker = 'snacks' },
  })
end

require('config')
require('lazy_setup')

if not vim.g.started_by_firenvim then
  require('util.work.overseer')
end
