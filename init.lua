local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then impatient.enable_profile() end


if vim.g.neovide then
  vim.cmd[[ set guifont=DMMono\ Nerd\ Font\ Mono:h11 ]]
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_scroll_animation_length = 0

  vim.g.neovide_remember_window_size = true
  vim.g.neovide_fullscreen = false
  function _G.toggle_full_screen()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end

  vim.api.nvim_set_keymap('n', '<F11>', ':lua toggle_full_screen()<cr>', {silent = true})
end

-- Windows configuration with powershell
if vim.loop.os_uname().sysname:lower():find('windows') then
  vim.o.shell = 'pwsh' -- let &shell = 'pwsh'
  vim.o.shellcmdflag='-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.o.shellredir = '| Out-File -Encoding UTF8'
end

vim.o.shellquote = ''
vim.o.shellpipe= '|'
vim.o.shellxquote= ''

vim.g.mapleader = ' '
vim.g.lsp_provider = 'nvim'

vim.g.python3_host_prog ='"C:/Windows/python3.exe'

vim.g.nvim_path = '$HOME/.config/nvim/'
vim.g.config_path = vim.g.nvim_path .. "config"
config_path = vim.g.config_path

require('plugins')

vim.g.nvim_path = '$HOME/.config/nvim/'
vim.g.config_path = vim.g.nvim_path .. 'config'

for _, config_file in ipairs({'plug', 'editor'}) do
  vim.g.config_file = config_file
  vim.cmd[[execute 'source ' . g:config_path . '/' . g:config_file . '.vim']]
end

vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd[[ colorscheme ayu ]]
