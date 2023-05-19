if vim.fn.executable('zsh') then
  vim.o.shell = 'zsh'
  vim.o.shellpipe = '|'
  vim.o.shellcmdflag='-ci'
end
