local ui_plugins = {

   -- colorscheme
   { url = 'git@gitlab.com:luco-bellic/ayu-vim.git', branch = 'personal', name = 'ayu',
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
      config = function()
         vim.o.termguicolors = true
         vim.o.background = "dark"
         vim.cmd [[ colorscheme ayu ]]
      end
   },

   -- icons
   { 'nvim-tree/nvim-web-devicons', config = function() require('plugin.ui.web-devicons') end },

   -- ui
   {
      'romgrk/barbar.nvim',
      enabled = true,
      config = function()
         require('plugin.ui.barbar')
      end,
      lazy = true,
      event = { 'BufRead' }
   },

   {
      'akinsho/bufferline.nvim',
      enabled = false,
      requires = 'nvim-tree/nvim-web-devicons',
      config = function()
         require('plugin.ui.bufferline')
      end
   },

   { 'glepnir/galaxyline.nvim', config = function() require('plugin.ui.galaxyline') end },

   -- git
   { 'lewis6991/gitsigns.nvim',
      event = 'BufRead',
      requires = 'plenary.nvim',
      config = function() require('plugin.ui.gitsigns') end
   },

   -- Color Syntax
   {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      dependencies = { 'HiPhish/nvim-ts-rainbow2' },
      config = function() require('plugin.ui.treesitter') end,
   },
   -- Start screen
   {
      'glepnir/dashboard-nvim',
      event = 'VimEnter',
      config = function()
         require('plugin.ui.dashboard')
      end
   },
   -- Scrollbar
   { 'petertriho/nvim-scrollbar', after = 'gitsigns.nvim', config = function() require('plugin.ui.scrollbar') end },

   -- Animation
   { 'echasnovski/mini.animate', event = "VeryLazy", config = function() require('plugin.ui.animate') end },

}

return ui_plugins
