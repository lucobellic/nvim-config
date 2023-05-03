vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'cpp' },
  command = 'setlocal commentstring=//\\ %s',
  desc = 'Set // as defalut comment string for c++',
})

-- TODO: restore cursor position
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = '*',
  command = ':%s/\\s\\+$//e',
  desc = 'Remove trailing whitespace on save',
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
