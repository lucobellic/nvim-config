vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--background-index-priority=background',
    '--all-scopes-completion',
    '--pch-storage=memory',
    '--completion-style=detailed',
    '--clang-tidy',
    '--enable-config',
    '--header-insertion=iwyu',
    '--all-scopes-completion',
    '-j',
    '2',
  },
})
