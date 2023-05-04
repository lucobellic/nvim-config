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
      'tsakirist/telescope-lazy.nvim',
      'GustavoKatel/telescope-asynctasks.nvim',
      'gbprod/yanky.nvim'
      -- 'prochri/telescope-all-recent.nvim',
    },
    config = function() require('plugins.telescope.telescope') end
  },

  { 'stevearc/dressing.nvim' },

  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    opts = require("plugins.telescope.chatgpt"),
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },

  {
    'paopaol/telescope-git-diffs.nvim',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
  },

}

return telescope_plugins
