if vim.g.vscode then
  local vscode = require('vscode')
  vim.keymap.set('n', '<leader>ue', function() vscode.action('shareedit.connect') end, { desc = 'Share Edit Start' })
  vim.keymap.set('n', '<leader>uE', function() vscode.action('shareedit.disconnect') end, { desc = 'Share Edit End' })
end

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
