return {
  'nvimdev/lspsaga.nvim',
  enabled = not vim.g.started_by_firenvim,
  event = 'LspAttach',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-treesitter/nvim-treesitter' },
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
        expand_collapse = nil,
      },
    },
    symbol_in_winbar = {
      enable = false,
      hide_keyword = true,
      separator = '   ',
      show_file = true,
    },
    rename = {
      in_select = false,
    },
    ui = {
      theme = 'round',
      border = vim.g.border.style,
      winblend = vim.o.pumblend,
      lines = { '', '', '', '', '' },
      expand = '',
      collapse = '',
      colors = {
        --float window normal background color
        normal_bg = '#0B0E14',
        --title background color
        title_bg = '#0D1017',
      },
    },
    code_action = {
      num_shortcut = true,
    },
  },
}
