local opts = { silent = true, noremap = true }

vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':FloatermHide<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 'n', '<esc>', ':FloatermHide<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-q>', ':FloatermKill<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-q>', '<C-\\><C-n>:FloatermKill<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-l>', ':FloatermNext<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', '<C-\\><C-n>:FloatermNext<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-h>', ':FloatermPrev<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-t>', ':FloatermNew<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-t>', '<C-\\><C-n>:FloatermNew<CR>', opts)

vim.wo.spell = false

vim.b.miniindentscope_disable = true
vim.b.minianimate_disable = true
