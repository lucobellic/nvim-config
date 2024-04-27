if vim.fn.executable('zsh') == 1 then
  vim.o.shell = 'zsh'
  vim.o.shellpipe = '|'
  vim.o.shellcmdflag='-c'
elseif vim.fn.executable('pwsh') == 1 then
  vim.o.shell = 'pwsh'
elseif vim.fn.executable('bash') == 1 then
  vim.o.shell = 'bash'
else
  vim.o.shell = 'sh'
end
