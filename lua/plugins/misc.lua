return {
    'nvim-lua/popup.nvim',
    {
      'nvim-lua/plenary.nvim',
      config = function()
        require('plenary.filetype').add_file('filetype')
      end
    },
    'dstein64/vim-startuptime',
    'kkharji/sqlite.lua',

    -- Tasks
    'skywind3000/asyncrun.vim',
    'skywind3000/asynctasks.vim',
    { 'GustavoKatel/telescope-asynctasks.nvim', dependencies = { 'asynctasks.vim' } },

    -- Other
    'lewis6991/impatient.nvim',
    'moll/vim-bbye', -- Close buffer and window
    'xolox/vim-misc',
    'honza/vim-snippets',
}
