return {
  'tpope/vim-fugitive',
  cmd = { 'Git' },
  keys = {
    { '<leader>gc', '<cmd>Git commit<cr>', desc = 'Git Commit' },
    { '<leader>ga', '<cmd>Git commit --amend<cr>', desc = 'Git Commit Amend' },
  },
}
