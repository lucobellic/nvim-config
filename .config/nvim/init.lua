local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then impatient.enable_profile() end

vim.o.shell = 'pwsh' -- let &shell = 'pwsh'

require('plugins')

vim.cmd[[
  set shellquote= shellpipe=\| shellxquote=
  set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
  set shellredir=\|\ Out-File\ -Encoding\ UTF8

  "let g:config_path = stdpath('config')
  let g:nvim_path    = '$HOME/.config/nvim/'
  let g:config_path  = g:nvim_path . 'config'
  execute 'source ' . g:nvim_path . '/' . 'plug.vim'

  " let g:lsp_provider = 'coc'
  let g:lsp_provider = 'nvim'
  let g:mapleader    = "\<Space>"


  set termguicolors     " enable true colors support
  set background=dark
  "set ayucolor="dark"   " for dark version of theme
  colorscheme ayu
]]

for _, config_file in ipairs({'editor', 'keybindings', 'search'}) do
  vim.g.config_file = config_file
  vim.cmd[[execute 'source ' . g:config_path . '/' . g:config_file . '.vim']]
end
