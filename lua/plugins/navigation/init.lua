return {
  {
    'junegunn/fzf.vim',
    dependencies = { 'junegunn/fzf' },
    event = 'VeryLazy',
    config = function()
      require('plugins.navigation.fzf')
    end
  },

  { 'ggandor/leap.nvim', enabled = false },
  { 'ggandor/flit.nvim', enabled = false },
  {
    'phaazon/hop.nvim',
    event = 'VeryLazy',
    branch = 'v2',
    config = function()
      require('plugins.navigation.hop')
    end
  },

  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'tpope/vim-fugitive', event = 'VeryLazy' },
  { 'tpope/vim-abolish',  event = 'VeryLazy' },

  require('plugins.navigation.neo-tree'),

  { 'tommcdo/vim-exchange', event = 'VeryLazy' },
  { 'tommcdo/vim-lion',     event = 'VeryLazy' },

}
