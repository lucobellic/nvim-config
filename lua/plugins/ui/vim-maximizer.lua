return {
  'szw/vim-maximizer',
  keys = {
    {
      '<leader>wM',
      function() vim.cmd('MaximizerToggle!') end,
      repeatable = true,
      desc = 'Toggle Maximizer',
    },
  },
  init = function()
    vim.g.maximizer_set_default_mapping = 0
    vim.g.maximizer_restore_on_winleave = 1
  end,
  config = function() end,
}
