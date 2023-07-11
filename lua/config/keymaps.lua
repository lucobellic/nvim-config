-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local util = require("lazyvim.util")
local opts = { silent = true, noremap = true }

-- Removed default keymaps
vim.keymap.del('n', '<leader>ud')
vim.keymap.del('n', '<leader>gg')
vim.keymap.del('n', '<leader>gG')

local wk = require('which-key')

-- NOTE: Set <c-f> keymap once again due to configuration issue
vim.keymap.set(
  'n',
  '<C-f>',
  function() require('telescope').extensions.live_grep_args.live_grep_args() end,
  { desc = 'Search Workspace' }
)

-- Toggle
wk.register({ ['<leader>ut'] = { ':TransparencyToggle<cr>', 'Toggle Transparency' } })
wk.register({
  ['<leader>ud'] = {
    name = 'Toggle Diagnostics',
    d = { util.toggle_diagnostics, 'Toggle Diagnostics' },
    t = { ':ToggleDiagnosticVirtualText<cr>', 'Toggle Virtual Text' },
    l = { ':ToggleDiagnosticVirtualLines<cr>', 'Toggle Virtual Lines' },
  }
})

-- Window management

vim.keymap.set('n', '<C-left>', require('smart-splits').resize_left, { desc = 'Resize left' })
vim.keymap.set('n', '<C-down>', require('smart-splits').resize_down, { desc = 'Resize down' })
vim.keymap.set('n', '<C-up>', require('smart-splits').resize_up, { desc = 'Resize up' })
vim.keymap.set('n', '<C-right>', require('smart-splits').resize_right, { desc = 'Resize right' })
vim.keymap.set('n', '<S-left>', require('smart-splits').move_cursor_left, { desc = 'Move cursor left' })
vim.keymap.set('n', '<S-down>', require('smart-splits').move_cursor_down, { desc = 'Move cursor down' })
vim.keymap.set('n', '<S-up>', require('smart-splits').move_cursor_up, { desc = 'Move cursor up' })
vim.keymap.set('n', '<S-right>', require('smart-splits').move_cursor_right, { desc = 'Move cursor right' })
vim.keymap.set('n', '<A-S-h>', require('smart-splits').swap_buf_left, { desc = 'Swap buffer left' })
vim.keymap.set('n', '<A-S-j>', require('smart-splits').swap_buf_down, { desc = 'Swap buffer down' })
vim.keymap.set('n', '<A-S-k>', require('smart-splits').swap_buf_up, { desc = 'Swap buffer up' })
vim.keymap.set('n', '<A-S-l>', require('smart-splits').swap_buf_right, { desc = 'Swap buffer right' })

vim.keymap.set('n', '<leader>qa', '<leader>qq', { remap = true, desc = 'Quit all' })

vim.api.nvim_set_keymap('c', '<esc>', '<C-c>', opts)
vim.api.nvim_set_keymap('t', '<esc>', '<C-\\><C-n>', opts)
vim.api.nvim_set_keymap('n', '<leader>wq', '<C-w>c', { desc = 'Delete window' })
vim.api.nvim_set_keymap('n', '<leader>w-', '<C-w>_', { desc = 'Max out the width' })
vim.api.nvim_set_keymap('n', '<leader>w|', '<C-w>|', { desc = 'Max out the height' })
vim.api.nvim_set_keymap('n', '<leader>wo', '<C-w>o', { desc = 'Close all other windows' })
vim.api.nvim_set_keymap('n', '<leader>ws', '<C-w>s', { desc = 'Split window' })
vim.api.nvim_set_keymap('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
vim.api.nvim_set_keymap('n', '<leader>wx', '<C-w>x', { desc = 'Swap current with next' })
vim.api.nvim_set_keymap('n', '<leader>wt', '<C-w>T', { desc = 'Break out into a next tab' })
vim.api.nvim_set_keymap('n', '<leader>wT', '<C-w>T', { desc = 'Break out into a next tab' })

vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>silent %y+<cr>', opts)

-- Spelling
vim.api.nvim_set_keymap('n', '>S', ']s', opts)
vim.api.nvim_set_keymap('n', '>s', ']s', opts)
vim.api.nvim_set_keymap('n', '<S', '[s', opts)
vim.api.nvim_set_keymap('n', '<s', '[s', opts)

-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", opts)
vim.api.nvim_set_keymap('v', '/', '"hy/<C-r>h', { silent = false, noremap = true })

-- Tab navigation
vim.keymap.del({ 'n', 't' }, '<C-k>')
vim.keymap.del({ 'n', 't' }, '<C-j>')
vim.keymap.set('n', '<C-k>', ':tabnext<cr>', { desc = 'Tab Next' })
vim.keymap.set('n', '<C-j>', ':tabprev<cr>', { desc = 'Tab Prev' })
vim.keymap.set('n', 'gn', ':tabnew<cr>', { desc = 'Tab New' })
vim.keymap.set('n', 'gq', ':tabclose<cr>', { desc = 'Tab Close' })

-- Copilot
wk.register({ ['<leader>cp'] = { ':Copilot panel<cr>', 'Copilot Panel' } })
