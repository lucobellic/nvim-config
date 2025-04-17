return {
  'kbwo/vim-shareedit',
  enalbed = not vim.g.vscode,
  dependencies = { 'vim-denops/denops.vim' },
  cmd = { 'ShareEditStart' },
  opts = {},
  dev = true,
  config = function() end,
}
