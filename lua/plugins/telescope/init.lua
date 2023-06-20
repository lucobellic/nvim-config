local telescope_plugins = {
  {
    'nvim-telescope/telescope.nvim',
    event = "VeryLazy",
    dependencies = {
      'plenary.nvim',
      'folke/trouble.nvim',
      'nvim-telescope/telescope-live-grep-args.nvim',
      'nvim-telescope/telescope-symbols.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      'nvim-telescope/telescope-smart-history.nvim',
      'tsakirist/telescope-lazy.nvim',
      'gbprod/yanky.nvim',
      'ThePrimeagen/refactoring.nvim',
      'rcarriga/nvim-notify'
      -- 'prochri/telescope-all-recent.nvim',
    },
    config = function() require('plugins.telescope.telescope') end
  },

  {
    'stevearc/dressing.nvim',
    event = "VeryLazy",
    config = function()
      require('plugins.telescope.dressing')
    end
  },

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
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
  },

}

return telescope_plugins
