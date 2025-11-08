return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'BufEnter',
  keys = {
    {
      '<leader>uk',
      function() require('treesitter-context').toggle() end,
      desc = 'Toggle Treesitter Context',
    },
  },
  opts = {
    line_numbers = true,
    max_lines = 5,
    min_window_height = 40,
    mode = 'topline',
    multiwindow = false,
    separator = not vim.g.winborder == 'solid' and '─' or ' ',
    trim_scope = 'inner',
  },
}
