vim.api.nvim_set_keymap('n', '<leader>j', "<cmd>lua require'hop'.hint_words()<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>j', "<cmd>lua require'hop'.hint_words()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", {})


local hop = require'hop'
hop.setup {
  perm_method = require'hop.perm'.TrieBacktrackFilling,
  reverse_distribution = false,
  term_seq_bias = 3 / 4,
  winblend = 50,
  teasing = true
}

vim.api.nvim_command("hi HopNextKey guifg=#FF8F40")
vim.api.nvim_command("hi HopNextKey1 guifg=#59C2FF")
vim.api.nvim_command("hi HopNextKey2 guifg=#C2D94C")
vim.api.nvim_command("hi HopUnmatched guifg=#4D5566")
-- vim.api.nvim_command("hi HopUnmatched guifg=#273747")
-- vim.api.nvim_command("hi HopUnmatched guifg=#1B2733")