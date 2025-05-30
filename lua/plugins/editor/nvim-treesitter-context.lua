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
    max_lines = 5,
    min_window_height = 40,
    mode = 'topline',
    line_numbers = true,
    trim_scope = 'inner',
    separator = '─',
  },
}
