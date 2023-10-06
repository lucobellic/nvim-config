return {
  'nvimdev/lspsaga.nvim',
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-treesitter/nvim-treesitter' }
  },
  keys = {
    { '<leader>go', '<cmd>Lspsaga outline<cr>', desc = 'Symbols Outline' }
  },
  opts = {
    diagnostic = {
      on_insert = false,
      border_follow = false,
    },
    lightbulb = { enable = false },
    outline = {
      auto_preview = false,
      keys = {
        jump = '<Enter>',
        expand_collapse = nil
      },
    },
    symbol_in_winbar = {
      enable = true,
      separator = ' -> ',
      show_file = false,
    },
    rename = {
      in_select = false
    },
    ui = {
      theme = 'round',
      border = 'rounded',
      winblend = vim.o.pumblend,
      lines = { '', '', '', '', '' },
      expand = '',
      collapse = '',
      colors = {
        --float window normal background color
        normal_bg = '#0B0E14',
        --title background color
        title_bg = '#0D1017',
      }
    },
    code_action = {
      num_shortcut = true
    }
  }
}
