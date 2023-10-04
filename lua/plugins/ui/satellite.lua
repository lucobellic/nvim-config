return {
  'lewis6991/satellite.nvim',
  event = 'BufEnter',
  opts = {
    current_only = true,
    handlers = {
      cursor = {
        enable = true,
        symbols = { '', '' },
      },
      search = {
        enable = true,
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
        key = 'm'
      },
      quickfix = {
        enable = false,
        signs = { '│', '│', '│' },
      }
    }
  }
}
