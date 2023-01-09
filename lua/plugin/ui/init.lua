local ui_plugins = {

   -- icons
   { 'kyazdani42/nvim-web-devicons', config = function() require('plugin.ui.web-devicons') end },

   -- ui
   { 'romgrk/barbar.nvim', config = function() require('plugin.ui.barbar') end },

   { 'glepnir/galaxyline.nvim', config = function() require('plugin.ui.galaxyline') end },

   -- git
   { 'lewis6991/gitsigns.nvim',
      event = 'BufRead',
      requires = 'plenary.nvim',
      config = function() require('plugin.ui.gitsigns') end
   },

   -- Color Syntax
   { 'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = function() require('plugin.ui.treesitter') end,
   },

   -- Start screen
   { 'glepnir/dashboard-nvim', config = function() require('plugin.ui.dashboard') end },

   -- Scrollbar
   { 'petertriho/nvim-scrollbar', after = 'gitsigns.nvim', config = function() require('plugin.ui.scrollbar') end },

}

return ui_plugins
