return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = function() return { 'User LazyBufEnter' } end,
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = function() return { 'User LazyBufEnter' } end,
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = function() return { 'User LazyBufEnter' } end,
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
      separator = (vim.g.winborder == 'none' or vim.g.winborder == 'solid') and ' ' or '─',
      trim_scope = 'inner',
      zindex = 20,
    },
  },
}
