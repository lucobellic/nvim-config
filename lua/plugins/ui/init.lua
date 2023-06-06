local ui_plugins = {

  -- colorscheme
  { 'rktjmp/lush.nvim' },
  {
    url = 'git@github.com:lucobellic/ayugloom.nvim.git',
    name = 'ayugloom',
    dependencies = 'rktjmp/lush.nvim',
    dev = true,
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.o.termguicolors = true
      vim.o.background = "dark"
      vim.g.transparent_colorscheme = false
      local toggle_transparency = function()
        vim.g.transparent_colorscheme = not vim.g.transparent_colorscheme
        if vim.g.transparent_colorscheme then
          vim.cmd("colorscheme ayubleak")
        else
          vim.cmd("colorscheme ayugloom")
        end
      end
      vim.api.nvim_create_user_command("TransparencyToggle", toggle_transparency, {})

      vim.cmd("colorscheme ayugloom")
    end,
  },

  {
    'catppuccin/nvim',
    event = 'VeryLazy',
    name = 'catppuccin'
  },

  {
    'folke/tokyonight.nvim',
    event = 'VeryLazy',
    name = 'tokyonight'
  },


  -- icons
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    opts = require('plugins.ui.web-devicons')
  },

  -- ui
  {
    'romgrk/barbar.nvim',
    lazy = false,
    dependencies = { 'folke/persistence.nvim' },
    config = function() require('plugins.ui.barbar') end,
  },

  {
    'akinsho/bufferline.nvim',
    enabled = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function() require('plugins.ui.bufferline') end
  },

  {
    'lucobellic/galaxyline.nvim',
    event = 'VeryLazy',
    branch = 'personal',
    config = function() require('plugins.ui.galaxyline') end,
  },

  -- git
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    requires = 'plenary.nvim',
    opts = require('plugins.ui.gitsigns')
  },

  -- Color Syntax
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'VeryLazy',
    dependencies = { 'HiPhish/nvim-ts-rainbow2' },
    config = function() require('plugins.ui.treesitter') end,
  },

  -- Start screen
  {
    'nvimdev/dashboard-nvim',
    lazy = false,
    priority = 100,
    dependencies = { 'folke/persistence.nvim', 'nvim-tree/nvim-web-devicons' },
    config = function() require('plugins.ui.dashboard') end
  },

  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    event = 'BufRead',
    dependencies = 'lewis6991/gitsigns.nvim',
    config = function() require('plugins.ui.scrollbar') end
  },

  -- Animation
  {
    'echasnovski/mini.animate',
    enabled = vim.g.neovide,
    event = "VeryLazy",
    config = function() require('plugins.ui.animate') end,
  },

  -- Windows auto resize
  {
    "anuvyklack/windows.nvim",
    event = 'VeryLazy',
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim"
    },
    config = function()
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require('windows').setup({
        ignore = {
          buftype = { 'quickfix', 'nofile' },
          filetype = { 'NvimTree', 'neo-tree', 'undotree', 'gundo', 'Outline' },
        },
      })
    end
  },

  {
    'mrjones2014/smart-splits.nvim',
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
  {
    'NvChad/nvim-colorizer.lua',
    event = 'VeryLazy',
    config = function() require('colorizer').setup() end,
  }
}

return ui_plugins
