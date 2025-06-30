return {
  'kbwo/vim-shareedit',
  enabled = not vim.g.vscode,
  dependencies = { 'vim-denops/denops.vim' },
  cmd = { 'ShareEditStart' },
  keys = {
    { '<leader>ue', '<cmd>ShareEditStart<cr>', desc = 'Share Edit Start' },
    { '<leader>uE', '<cmd>ShareEditEnd<cr>', desc = 'Share Edit End' },
  },
  opts = {},
  dev = true,
  config = function() end,
}
