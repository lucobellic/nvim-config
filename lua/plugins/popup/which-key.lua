return {
  'folke/which-key.nvim',
  opts = {
    preset = 'helix',
    delay = 300,
    show_help = false, -- show help message on the command line when the popup is visible
    show_keys = false, -- show the currently pressed key and its label as a message in the command line
    notify = false,
    layout = {
      spacing = 3, -- spacing between columns
      align = 'center', -- align columns left, center or right
    },
    triggers = {
      { '<auto>', mode = 'nxso' },
      { '<localleader>', mode = 'nxso' },
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
      width = { min = 35, max = 35 },
      height = { max = 120 },
      border = vim.g.winborder,
      wo = { winblend = vim.o.winblend },
    },
    sort = { 'alphanum', 'local', 'order', 'mod' },
  },
}
