vim.keymap.del('n', '<leader>n')
vim.keymap.del('n', '<leader>e')
vim.keymap.del('n', '<leader>.')
vim.keymap.del('n', '<leader>ud')

vim.keymap.set({ 'n', 'v' }, 'c', '<cmd>lua vim.g.change = true<cr>c', { noremap = true, desc = 'Change' })
