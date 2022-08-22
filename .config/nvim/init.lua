local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then impatient.enable_profile() end

-- Windows configuration with powershell
if vim.loop.os_uname().sysname:lower():find('windows') then
  vim.o.shell = 'pwsh' -- let &shell = 'pwsh'
  vim.o.shellcmdflag='-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.o.shellredir = '| Out-File -Encoding UTF8'
end

vim.o.shellquote = ''
vim.o.shellpipe= '|'
vim.o.shellxquote= ''


vim.g.mapleader = "<Space>"
vim.g.lsp_provider = 'nvim'

require('plugins')

vim.g.nvim_path = '$HOME/.config/nvim/'
vim.g.config_path = vim.g.nvim_path .. 'config'

vim.cmd[[
  execute 'source ' . g:nvim_path . '/' . 'plug.vim'

  set termguicolors     " enable true colors support
  set background=dark
  "set ayucolor="dark"   " for dark version of theme
  colorscheme ayu
]]

for _, config_file in ipairs({'editor', 'keybindings', 'search'}) do
  vim.g.config_file = config_file
  vim.cmd[[execute 'source ' . g:config_path . '/' . g:config_file . '.vim']]
end
