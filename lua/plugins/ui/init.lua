local ui_plugins = {

  -- colorscheme
  { 'rktjmp/lush.nvim' },
  {
    url = 'git@github.com:lucobellic/ayu-dark.git',
    branch = 'personal',
    name = 'ayu',
  },
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

  -- icons
  { 'nvim-tree/nvim-web-devicons', opts = require('plugins.ui.web-devicons') },

  -- ui
  {
    'romgrk/barbar.nvim',
    ft = 'neo-tree',
    config = function() require('plugins.ui.barbar') end,
  },

  {
    'akinsho/bufferline.nvim',
    enabled = false,
    requires = 'nvim-tree/nvim-web-devicons',
    config = function() require('plugins.ui.bufferline') end
  },

  {
    'glepnir/galaxyline.nvim',
    config = function() require('plugins.ui.galaxyline') end,
  },

  -- git
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufRead',
    requires = 'plenary.nvim',
    opts = require('plugins.ui.gitsigns')
  },

  -- Color Syntax
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'HiPhish/nvim-ts-rainbow2' },
    config = function() require('plugins.ui.treesitter') end,
  },

  -- Start screen
  {
    'glepnir/dashboard-nvim',
    event = 'VimEnter',
    config = function() require('plugins.ui.dashboard') end
  },

  -- Scrollbar
  {
    'petertriho/nvim-scrollbar',
    dependencies = 'lewis6991/gitsigns.nvim',
    config = function() require('plugins.ui.scrollbar') end
  },

  -- Animation
  {
    'echasnovski/mini.animate',
    event = "VeryLazy",
    config = function() require('plugins.ui.animate') end,
  },
}

return ui_plugins
