--- @type 'astronvim'|'lazyvim'
vim.g.distribution = 'lazyvim'

-- Set border style
vim.g.winborder = 'single'
local enable_border = true
vim.g.border = {
  enabled = enable_border,
  style = enable_border and vim.g.winborder or { ' ' },
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

-- Enable OSC 52 inside docker
if vim.env.INSIDE_DOCKER then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
    cache_enabled = true,
  }
end

local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  -- Add custom repeatable option
  if opts.repeatable then
    ---@diagnostic disable-next-line: inject-field
    opts.repeatable = nil
    return keymap_set(mode, lhs, function(...)
      rhs(...)
      vim.fn['repeat#set'](vim.api.nvim_replace_termcodes(lhs, true, false, true))
    end, opts)
  end
  return keymap_set(mode, lhs, rhs, opts)
end

if vim.g.distribution ~= 'lazyvim' then
  require('config.options')
  require('config.autocmds')
end

require('config.shell')
require('config.lazy')
require('config.diagnostic')
require('config.filetype')
require('config.neovide')

if not vim.g.started_by_firenvim then
  require('util.work.overseer')
end
