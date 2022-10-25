local hop = require('hop')
hop.setup {
  perm_method = require('hop.perm').TrieBacktrackFilling,
  reverse_distribution = false,
  case_insensitive = true,
  term_seq_bias = 3 / 4,
  winblend = 50,
  teasing = true
}

vim.api.nvim_set_keymap('n', '<leader>j', "<cmd>lua require'hop'.hint_words()<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>j', "<cmd>lua require'hop'.hint_words()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>J', "<cmd>lua require'hop'.hint_words({multi_windows = true})<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>J', "<cmd>lua require'hop'.hint_words({multi_windows = true})<cr>", {})

vim.api.nvim_set_keymap('n', '<leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>L', "<cmd>lua require'hop'.hint_lines({multi_windows = true})<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>L', "<cmd>lua require'hop'.hint_lines({multi_windows = true})<cr>", {})

vim.api.nvim_set_keymap('n', '<leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.api.nvim_set_keymap('n', '<leader>S', "<cmd>lua require'hop'.hint_char1({multi_windows = true})<cr>", {})
vim.api.nvim_set_keymap('v', '<leader>S', "<cmd>lua require'hop'.hint_char1({multi_windows = true})<cr>", {})
