local navigation_plugins = {
  {
    'junegunn/fzf.vim',
    event = 'VeryLazy',
    config = function()
      require('plugins.navigation.fzf')
    end
  },

  {
    'phaazon/hop.nvim',
    event = 'VeryLazy',
    branch = 'v2',
    config = function()
      require('plugins.navigation.hop')
    end
  },

  {
    'mrjones2014/legendary.nvim',
    event = 'VeryLazy',
    config = function()
      require('plugins.navigation.legendary')
    end
  },

  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'tpope/vim-fugitive', event = 'VeryLazy' },
  { 'tpope/vim-repeat',   event = 'VeryLazy' },
  { 'tpope/vim-abolish',  event = 'VeryLazy' },

  {
    'echasnovski/mini.comment',
    config = function()
      require('mini.comment').setup()
    end
  },

  -- { 'kyazdani42/nvim-tree.lua', config = function() require('plugins.navigation.tree') end },
  {
    'nvim-neo-tree/neo-tree.nvim',
    event = 'VeryLazy',
    branch = 'v2.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    },
    config = function()
      require('plugins.navigation.neo-tree')
    end
  },

  { 'tommcdo/vim-exchange', event = 'VeryLazy' },
  { 'tommcdo/vim-lion',     event = 'VeryLazy' },
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    branch = 'stable',
    config = function() require('mini.ai').setup() end
  },

}

return navigation_plugins
