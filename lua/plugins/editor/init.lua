local editor_plugins = {
  require('plugins.editor.zenmode'),
  {
  },
  {
    'junegunn/limelight.vim',
    event = "VeryLazy",
    config = function() require('plugins.editor.limelight') end
  }, -- Highlight paragraph

  {
    'lukas-reineke/indent-blankline.nvim',
    opts = require('plugins.editor.indent-blankline')
  },
  {
    'echasnovski/mini.indentscope',
    opts = require('plugins.editor.indentscope')
  },
  require('plugins.editor.diffview'),
  {
    'kevinhwang91/nvim-ufo',
    event = 'VeryLazy',
    dependencies = { 'kevinhwang91/promise-async' },
    opts = {},
    init = function()
      -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
      vim.keymap.set("n", "zR", function()
        require("ufo").openAllFolds()
      end)
      vim.keymap.set("n", "zM", function()
        require("ufo").closeAllFolds()
      end)
    end
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
    'nvim-pack/nvim-spectre',
    opts = {
      highlight = {
        ui = 'Title',
        search = 'Search',
        replace = 'Substitute',
      },
      result_padding = '▏  ',
    }
  },
  { 'RRethy/vim-illuminate', enabled = false },
  {
    'andymass/vim-matchup',
    event = "VeryLazy",
    opts = {},
    config = function()
      vim.g.matchup_matchparen_offscreen = {}
    end
  },
  require('plugins.editor.yanky'),
}

return editor_plugins
