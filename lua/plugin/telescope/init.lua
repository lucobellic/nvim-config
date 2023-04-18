local telescope_plugins = {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'plenary.nvim',
      'folke/trouble.nvim',
      'nvim-telescope/telescope-live-grep-args.nvim',
      'nvim-telescope/telescope-symbols.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      -- 'prochri/telescope-all-recent.nvim',
    },
    config = function() require('plugin.telescope.telescope') end
  },

  { 'stevearc/dressing.nvim', config = function() require('plugin.telescope.dressing') end },

}

return telescope_plugins
