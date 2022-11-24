return { config = function(use)
  -- icons
  use { 'kyazdani42/nvim-web-devicons', config = function() require('plugin.ui.web-devicons') end }

  -- ui
  use { 'romgrk/barbar.nvim', config = function() require('plugin.ui.barbar') end }

  use { 'glepnir/galaxyline.nvim', config = function() require('plugin.ui.galaxyline') end }

  -- git
  use { 'lewis6991/gitsigns.nvim',
    event = 'BufRead',
    requires = 'plenary.nvim',
    config = function() require('plugin.ui.gitsigns') end
  }

  -- Color Syntax
  use { 'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function() require('plugin.ui.treesitter') end
  }

  -- Start screen
  use { 'glepnir/dashboard-nvim', config = function() require('plugin.ui.dashboard') end }

  -- Scrollbar
  use { 'petertriho/nvim-scrollbar', after = 'gitsigns.nvim', config = function() require('plugin.ui.scrollbar') end }

  -- Enhanced wilder
  use { 'gelguy/wilder.nvim', config = function() require('plugin.ui.wilder') end, requires ='romgrk/fzy-lua-native' }

end
}
