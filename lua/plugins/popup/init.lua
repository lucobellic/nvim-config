local popup_plugins = {

  { 'folke/trouble.nvim', event = "VeryLazy" },

  -- Session manager
  {
    'folke/persistence.nvim',
    lazy = false,
    config = function()
      require('plugins.popup.persistence')
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = "VeryLazy",
    after = 'trouble.nvim',
    config = function() require('plugins.popup.todo') end
  },

  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    config = function() require('plugins.popup.whichkey') end
  },

  -- Enhanced wilder
  {
    'lucobellic/wilder.nvim',
    event = "VeryLazy",
    branch = 'personal',
    config = function()
      require('plugins.popup.wilder')
    end,
    dependencies = { 'romgrk/fzy-lua-native' },
  },

  {
    'rcarriga/nvim-notify',
    config = function()
      require('plugins.popup.notify')
    end
  },

  {
    'folke/noice.nvim',
    config = function()
      require('plugins.popup.noice')
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify'
    },
  },

  {
    'lucobellic/vim-floaterm',
    event = "VeryLazy",
    branch = 'personal',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('plugins.popup.floaterm')
    end
  }, -- Floating terminal

  {
    'akinsho/toggleterm.nvim',
    event = "VeryLazy",
    config = function() require('plugins.popup.toggleterm') end
  },
}

return popup_plugins
