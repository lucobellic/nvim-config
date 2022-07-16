return {config = function(use)
    -- icons
    use {'kyazdani42/nvim-web-devicons', config = function() require('plugin.ui.web-devicons') end}

    -- ui
    use {'romgrk/barbar.nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'barbar.vim') end}
    use {'glepnir/galaxyline.nvim', config = function() require('plugin.ui.galaxyline') end}

    -- git
    use {'lewis6991/gitsigns.nvim',
      requires = 'plenary.nvim',
      config = function() require('plugin.ui.gitsigns') end
    }

    -- Color Syntax
    use {'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      config = function() require('plugin.ui.treesitter') end
    }

    use {'glepnir/dashboard-nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'dashboard.vim') end}  -- Start screen

  end
}
