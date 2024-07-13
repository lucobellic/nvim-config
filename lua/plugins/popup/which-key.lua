return {
  'folke/which-key.nvim',
  opts = {
    show_help = false, -- show help message on the command line when the popup is visible
    show_keys = false, -- show the currently pressed key and its label as a message in the command line
    layout = {
      spacing = 3, -- spacing between columns
      align = 'center', -- align columns left, center or right
    },
    icons = {
      rules = false,
      breadcrumb = ' ', -- symbol used in the command line area that shows your active key combo
      separator = '➜', -- symbol used between a key and it's label
      group = '', -- symbol prepended to a group
      mappings = false,
    },
    win = {
      no_overlap = false,
      border = vim.g.border.enabled and { '─', '─', '─', '', '─', '─', '─', '' } or { ' ' },
      padding = { 1, 5, 0, 5 }, -- extra window padding [top, right, bottom, left]
      wo = {
        winblend = vim.o.winblend,
      },
    },
  },
}
