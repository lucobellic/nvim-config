local popup_plugins = {

  { 'folke/trouble.nvim' },

  -- Session manager
  {
    'folke/persistence.nvim',
    module = 'persistence',
    config = function()
      require('plugins.popup.persistence')
    end,
  },

  {
    'folke/todo-comments.nvim',
    after = 'trouble.nvim',
    config = function() require('plugins.popup.todo') end
  },

  { 'folke/which-key.nvim', config = function() require('plugins.popup.whichkey') end },

  -- Enhanced wilder
  {
    'lucobellic/wilder.nvim',
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
    branch = 'personal',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('plugins.popup.floaterm')
    end
  }, -- Floating terminal

  { 'akinsho/toggleterm.nvim', config = function() require('plugins.popup.toggleterm') end },
}

return popup_plugins
