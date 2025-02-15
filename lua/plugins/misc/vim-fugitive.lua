return {
  'tpope/vim-fugitive',
  cmd = { 'Git' },
  keys = {
    { '<leader>gc', ':Git commit<cr>', desc = 'Git Commit' },
    { '<leader>ga', ':Git commit --amend<cr>', desc = 'Git Commit Amend' },
  },
}
