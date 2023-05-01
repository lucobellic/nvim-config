vim.o.shellquote = ''
vim.o.shellpipe = '|'
vim.o.shellxquote = ''

if vim.fn.executable('zsh') then
  vim.o.shell = 'zsh'
end

