return {
  'stevearc/conform.nvim',
  keys = {
    {
      '<leader>cF',
      function() require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 }) end,
      mode = { 'n', 'v' },
      desc = 'Format Injected Langs',
    },
  },
  opts = {},
}
