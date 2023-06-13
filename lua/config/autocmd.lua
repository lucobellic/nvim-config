vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'cpp' },
  command = 'setlocal commentstring=//\\ %s',
  desc = 'Set // as defalut comment string for c++',
})

-- Display cursorline only in focused window
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'WinEnter' }, {
  pattern = '*',
  command = 'setlocal cursorline',
  desc = 'Display cursorline only in focused window',
})
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  pattern = '*',
  command = 'setlocal nocursorline',
  desc = 'Hide cursorline when leaving window',
})
