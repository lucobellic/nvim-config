return {
  { 'nvim-lua/popup.nvim', event = 'VeryLazy' },
  {
    'nvim-lua/plenary.nvim',
    config = function()
      require('plenary.filetype').add_file('filetype')
    end
  },
  { 'kkharji/sqlite.lua',  event = 'VeryLazy' },

  -- Other
  { 'moll/vim-bbye',       event = 'VeryLazy' },     -- Close buffer and window
  { 'xolox/vim-misc',      event = 'VeryLazy' },
  { 'honza/vim-snippets',  event = 'VeryLazy' }
}
