-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'cpp' },
  command = 'setlocal commentstring=//\\ %s',
  desc = 'Set // as default comment string for c++',
})

-- Terminal option
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern = { '*' },
  callback = function()
    vim.b.minianimate_disable = true
    vim.b.miniindentscope_disable = true
    vim.opt_local.spell = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
  desc = 'Set terminal buffer options',
})

-- Display cursorline only in focused window
vim.api.nvim_create_autocmd({ 'WinEnter' }, {
  pattern = '*',
  callback = function(ev) vim.api.nvim_set_option_value('cursorline', true, { win = ev.win }) end,
  desc = 'Display cursorline only in focused window',
})

vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  pattern = '*',
  callback = function(ev)
    local current_filetype = vim.api.nvim_get_option_value('filetype', { buf = ev.buf }):lower()
    local ignored_list = { 'neo-tree', 'outline' }
    if not vim.tbl_contains(ignored_list, function(ft) return ft == current_filetype end, { predicate = true }) then
      vim.api.nvim_set_option_value('cursorline', false, { win = ev.win })
    end
  end,
  desc = 'Hide cursorline when leaving window',
})

-- Automatic save
require('util.autosave').setup()

-- Load session from persistence
local persistence_util = require('util.persistence')
vim.api.nvim_create_user_command('PersistenceLoadSession', persistence_util.select_session, {})

-- Switch colorscheme with transparency
vim.g.transparent_colorscheme = false
local toggle_transparency = function()
  if vim.g.transparent_colorscheme then
    vim.cmd('colorscheme ayugloom')
  else
    vim.cmd('colorscheme ayubleak')
  end
  vim.g.transparent_colorscheme = not vim.g.transparent_colorscheme
end
vim.api.nvim_create_user_command('TransparencyToggle', toggle_transparency, {})

vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

-- Always focus on buffer after tab change
vim.api.nvim_create_autocmd({ 'TabEnter' }, {
  pattern = { '*' },
  callback = function() require('util.tabpages').focus_first_listed_buffer() end,
})

-- Repeat change with dot repeat
local change_text = ''

local function repeat_change()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('cgn' .. change_text .. '<esc>', true, false, true), 'n', false)
end

vim.api.nvim_create_user_command('RepeatChange', repeat_change, { desc = 'Repeat last change' })

vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  pattern = { '*' },
  callback = function()
    if vim.g.change then
      change_text = vim.fn.getreg('.')
      vim.fn.setreg('/', vim.fn.getreg('"', 1))
      vim.g.change = false
      vim.fn['repeat#set'](vim.api.nvim_replace_termcodes('<cmd>RepeatChange<cr>', true, false, true))
    end
  end,
})
