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

vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>silent %y+<cr>', opts)
vim.keymap.set('n', '<leader>qa', '<leader>qq', { remap = true, desc = 'Quit all' })

vim.api.nvim_set_keymap('c', '<esc>', '<C-c>', opts)
vim.api.nvim_set_keymap('t', '<esc>', '<C-\\><C-n>', opts)
vim.api.nvim_set_keymap('n', '<leader>w', '<C-w>', { noremap = false })
vim.keymap.set('n', '<C-w>q', '<C-w>c', { desc = 'Delete window', remap = true })

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
