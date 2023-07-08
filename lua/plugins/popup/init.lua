local popup_plugins = {

  -- Session manager
  {
    'folke/persistence.nvim',
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
      pre_save = function() vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' }) end
    }
  },

  {
    'folke/todo-comments.nvim',
    opts = require('plugins.popup.todo')
  },

  {
    'folke/which-key.nvim',
    opts = {
      show_help = false,                -- show help message on the command line when the popup is visible
      show_keys = false,                -- show the currently pressed key and its label as a message in the command line
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3,                    -- spacing between columns
        align = "center",               -- align columns left, center or right
      },
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
      },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "⁘ ",   -- symbol prepended to a group
      },
    }
  },

  -- Enhanced wilder
  {
    'lucobellic/wilder.nvim',
    event = 'VeryLazy',
    branch = 'personal',
    config = function()
      require('plugins.popup.wilder')
    end,
    dependencies = { 'romgrk/fzy-lua-native' },
  },

  require('plugins.popup.notify'),
  require('plugins.popup.noice'),
  require('plugins.popup.floaterm'),
  require('plugins.popup.toggleterm'),
  require('plugins.popup.trouble'),
}

return popup_plugins
