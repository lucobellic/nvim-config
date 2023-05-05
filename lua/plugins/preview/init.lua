local preview_plugins = {

  { 'folke/trouble.nvim' },

  -- Session manager
  {
    'folke/persistence.nvim',
    event = 'VeryLazy',
    module = 'persistence',
    config = function()
      require('plugins.preview.persistence')
    end,
  },

  {
    'folke/todo-comments.nvim',
    after = 'trouble.nvim',
    config = function() require('plugins.preview.todo') end
  },

  { 'folke/which-key.nvim', config = function() require('plugins.preview.whichkey') end },

  -- Enhanced wilder
  {
    'lucobellic/wilder.nvim',
    branch = 'personal',
    config = function()
      require('plugins.preview.wilder')
    end,
    dependencies = { 'romgrk/fzy-lua-native' },
  },

  {
    'folke/noice.nvim',
    config = function()
      require('plugins.preview.noice')
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify'
    },
  },

  {
    'voldikss/vim-floaterm',
    config = function()
      require('plugins.preview.floaterm')
    end
  }, -- Floating terminal

  { 'akinsho/toggleterm.nvim', config = function() require('plugins.preview.toggleterm') end },
}

return preview_plugins
