return {
  'kbwo/vim-shareedit',
  enabled = not vim.g.vscode,
  dependencies = { 'vim-denops/denops.vim' },
  cmd = { 'ShareEditStart' },
  opts = {},
  dev = true,
  config = function() end,
}
