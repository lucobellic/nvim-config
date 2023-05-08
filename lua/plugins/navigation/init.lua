local navigation_plugins = {
  {
    'junegunn/fzf',
    run = 'fzf#install()'
  },

  {
    'junegunn/fzf.vim',
    config = function()
      require('plugins.navigation.fzf')
    end
  },

  {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
      require('plugins.navigation.hop')
    end
  },

  'tpope/vim-surround',
  'tpope/vim-commentary',
  'tpope/vim-fugitive',
  'tpope/vim-repeat',
  'tpope/vim-abolish',

  -- { 'kyazdani42/nvim-tree.lua', config = function() require('plugins.navigation.tree') end },
  {
    'nvim-neo-tree/neo-tree.nvim',
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

  'tommcdo/vim-exchange',
  'tommcdo/vim-lion',
  { 'echasnovski/mini.ai', branch = 'stable', config = function() require('mini.ai').setup() end },

}

return navigation_plugins
