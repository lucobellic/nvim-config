return {
  'stevearc/conform.nvim',
  opts = {
    formatters_by_ft = {
      cpp = { 'clang_format' },
      markdown = { 'markdownlint-cli2', 'markdown-toc' },
    },
  },
}
