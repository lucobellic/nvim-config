return {
  'lewis6991/satellite.nvim',
  event = 'BufEnter',
  enabled = vim.fn.has('nvim-0.10') == 1,
  opts = {
    current_only = true,
    winblend = vim.o.winblend,
    excluded_filetypes = { 'OverseerList', '', 'chatgpt-input', '' },
    handlers = {
      cursor = {
        enable = false,
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
