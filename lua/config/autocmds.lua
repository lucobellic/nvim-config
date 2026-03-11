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
    vim.opt_local.wrap = false
    vim.opt_local.foldcolumn = '0'
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.statuscolumn = ''
  end,
  desc = 'Set terminal buffer options',
})

-- Automatic save
require('util.autosave').setup()

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
local change_tick = -1 -- b:changedtick at the time the change was registered

local function repeat_change()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('cgn' .. change_text .. '<esc>', true, false, true), 'n', false)
end

vim.api.nvim_create_user_command('RepeatChange', repeat_change, { desc = 'Repeat last change' })

vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
  pattern = { '*' },
  callback = function()
    if vim.g.change then
      change_text = vim.fn.keytrans(vim.fn.getreg('.'))
      vim.fn.setreg('/', vim.fn.getreg('"', 1))
      change_tick = vim.b.changedtick
      vim.g.change = false
    end
  end,
})

-- Remap '.' to call repeat_change when the last registered change is current,
-- otherwise fall through to native dot-repeat. This is the same strategy used
-- by vim-repeat but implemented natively in Lua.
vim.keymap.set('n', '.', function()
  if change_tick == vim.b.changedtick then
    repeat_change()
  else
    vim.api.nvim_feedkeys('.', 'n', false)
  end
end, { desc = 'Dot repeat (change-aware)' })

-- Set toggleterm filetype to terminal buffer with toggleterm name
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*toggleterm*' },
  callback = function(ev)
    if
      vim.api.nvim_buf_is_valid(ev.buf)
      and vim.api.nvim_get_option_value('filetype', { buf = ev.buf }) == ''
      and vim.api.nvim_get_option_value('buftype', { buf = ev.buf }) == 'terminal'
    then
      vim.api.nvim_set_option_value('filetype', 'toggleterm', { buf = ev.buf })
    end
  end,
})

local augroup = vim.api.nvim_create_augroup('LazyBufEnter', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  callback = function(ev)
    local filetype = vim.bo[ev.buf].filetype
    if filetype ~= '' and not filetype:match('^snacks.*') then
      vim.api.nvim_exec_autocmds('User', { pattern = 'LazyBufEnter', modeline = false, data = ev })
      vim.api.nvim_clear_autocmds({ group = augroup })
    end
  end,
})

-- Create command from keymaps
require('util.commands').create_command_from_keymaps()
-- Create command to toggle fold virtual text
require('util.folds.folds').setup()

-- Track visited files by keeping a list in a global variable
require('util.commands').track_visited_files()
-- Create block spinner command
require('util.commands').create_block_spinner_command()
-- Setup window resize utility
require('util.commands').setup_window_resize({
  min_width = 80,
  min_height = 20,
  ignore_buftypes = { 'nofile', 'prompt', 'popup', 'quickfix' },
  ignore_filetypes = { 'neo-tree', 'opencode', 'cursor', 'gemini' },
})
