return {
  'lewis6991/satellite.nvim',
  event = 'BufEnter',
  opts = {
    current_only = true,
    excluded_filetypes = { 'OverseerList' },
    handlers = {
      cursor = {
        enable = true,
        symbols = { '', '' },
      },
      search = {
        enable = true,
        priority = 55, -- Below cursor and above diagnostic
      },
      diagnostic = {
        enable = true,
        signs = { '│', '│', '│' },
        min_severity = vim.diagnostic.severity.WARN,
      },
      gitsigns = {
        enable = true,
        signs = {
          add = '│',
          change = '│',
          delete = '│',
        },
      },
      marks = {
        enable = false,
        show_builtins = false, -- shows the builtin marks like [ ] < >
        key = 'm',
      },
      quickfix = {
        enable = false,
        signs = { '│', '│', '│' },
      },
    },
  },
}
