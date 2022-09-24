-- paste over currently selected text without yanking it
vim.api.nvim_set_keymap('v', 'p', 'p :let @"=@0 | let @*=@0 | let @+=@0<cr>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('v', 'P', 'P :let @"=@0 | let @*=@0 | let @+=@0<cr>', {silent = true, noremap = true})


vim.api.nvim_set_keymap('n', '<leader>p', ':<C-u>bo 20split tmp<cr>:terminal<cr>', {silent = true, noremap = true})

vim.api.nvim_set_keymap('n', '<leader>gc',     ':<C-u>Git commit<cr>', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>ga',     ':<C-u>Git commit --amend<cr>', {silent = true, noremap=true})

vim.api.nvim_set_keymap('n', '<Esc>',       ':nohl<cr>', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>w', '<C-w>', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>wd', ':Bdelete<cr>', {silent = true, noremap=true})


-- Navigation

vim.api.nvim_set_keymap('n', '<C-left>',      ':vertical resize +5<cr>', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<C-down>',      ':resize -5<cr>', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<C-up>',        ':resize +5<cr>', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<C-right>',     ':vertical resize -5<cr>', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-left>',      '<C-w>h', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-down>',      '<C-w>j', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-up>',        '<C-w>k', {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-right>',     '<C-w>l', {silent = true, noremap=true})

-- Escape terminal insert mode and floating terminal
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n', {silent = true, noremap=true})
