local ui_plugins = {

  require('plugins.ui.gitsigns'),

  -- ui
  { 'akinsho/bufferline.nvim',   enabled = false },
  require('plugins.ui.barbar'),

  {
    'tiagovla/scope.nvim',
    event = 'VeryLazy',
    config = function()
      require('scope').setup({ restore_state = true })
    end
  },

  { 'nvim-lualine/lualine.nvim', enabled = false },
  {
    'lucobellic/galaxyline.nvim',
    enabled = true,
    event = 'VeryLazy',
    branch = 'personal',
    config = function() require('plugins.ui.galaxyline') end,
  },

  -- Start screen
  { 'goolord/alpha-nvim', enabled = false },
  require('plugins.ui.dashboard'),

  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    event = 'BufRead',
    dependencies = 'lewis6991/gitsigns.nvim',
    config = function() require('plugins.ui.scrollbar') end
  },

  -- Windows auto resize
  {
    'anuvyklack/windows.nvim',
    event = 'VeryLazy',
    dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim'
    },
    init = function()
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false
    end,
    config = function()
      require('windows').setup({
        ignore = {
          buftype = { 'quickfix', 'nofile', 'neo-tree' },
          filetype = {
            'NvimTree',
            'neo-tree',
            'undotree',
            'undo',
            'Outline',
            'dapui_scopes',
            'dapui_breakpoints',
            'dapui_stacks',
            'dapui_watches'
          },
        },
        animation = {
          enable = false,
          duration = 500,
          fps = 60,
          easing = 'in_out_sine'
        }
      })
    end
  },
  {
    'folke/edgy.nvim',
    enabled = false,
    event = 'VeryLazy',
    opts = require('plugins.ui.edgy')
  },
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VeryLazy',
    config = function()
      require('smart-splits').setup({
        -- Ignored filetypes (only while resizing)
        ignored_filetypes = {
          'nofile',
          'quickfix',
          'prompt',
        },
        -- Ignored buffer types (only while resizing)
        ignored_buftypes = { 'NvimTree', 'neo-tree' },
        smart_splits = {},
      })
    end
  },

  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    config = function() require('plugins.ui.incline') end
  },

  -- Colors
  require('plugins.ui.treesitter'),
  {
    'NvChad/nvim-colorizer.lua',
    event = 'VeryLazy',
    config = function() require('colorizer').setup() end,
  }
}

return ui_plugins
