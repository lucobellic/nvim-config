local editor_plugins = {
  {
    'folke/zen-mode.nvim',
    event = "VeryLazy",
    config = function()
      require('plugins.editor.zenmode')
    end
  },
  {
    'junegunn/limelight.vim',
    event = "VeryLazy",
    config = function() require('plugins.editor.limelight') end
  }, -- Highlight paragraph

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    config = function()
      require('plugins.editor.indent-blankline')
    end
  },
  {
    'echasnovski/mini.indentscope',
    event = "VeryLazy",
    branch = 'stable',
    config = function()
      require('plugins.editor.indentscope')
    end
  },
  {
    'sindrets/diffview.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('plugins.editor.diffview') end
  },
  {
    'kevinhwang91/nvim-ufo',
    event = "VeryLazy",
    dependencies = { 'kevinhwang91/promise-async' },
    config = function() require('plugins.editor.fold') end
  },
  {
    'echasnovski/mini.splitjoin',
    event = "VeryLazy",
    config = function()
      require('mini.splitjoin').setup({
        mappings = {
          toggle = '<leader>S',
          split = '',
          join = '',
        },
      })
    end
  },
  {
    'echasnovski/mini.move',
    event = "VeryLazy",
    version = '*',
    config = function()
      require('mini.move').setup({
        mappings = {
          left = '',
          right = '',
          line_left = '',
          line_right = '',
        }
      })
    end
  },
  {
    'windwp/nvim-spectre',
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('plugins.editor.spectre') end
  },
  {
    'RRethy/vim-illuminate',
    event = "VeryLazy",
    config = function() require('plugins.editor.illuminate') end
  },
  {
    'andymass/vim-matchup',
    event = "VeryLazy",
    config = function()
      vim.g.matchup_matchparen_offscreen = {}
    end
  },

  -- Yank
  {
    'gbprod/yanky.nvim',
    event = "VeryLazy",
    dependencies = { 'kkharji/sqlite.lua' },
    config = function()
      require('plugins.editor.yanky')
    end
  },
}

return editor_plugins
