return {
  'nvim-treesitter/nvim-treesitter-context',
  enabled = false,
  opts = {
    max_lines = 3,
    line_numbers = true,
    trim_scope = 'inner',
    separator = vim.g.neovide and ' ' or '·',
  },
}
