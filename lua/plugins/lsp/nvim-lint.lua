return {
  'mfussenegger/nvim-lint',
  opts = {
    formatters_by_ft = {
      ['rst'] = { 'rstcheck' },
    },
    linters = {
      ['markdownlint-cli2'] = {
        args = { '--config', vim.fn.stdpath('config') .. '/.markdownlint.jsonc', '-' },
      },
    },
  },
}
