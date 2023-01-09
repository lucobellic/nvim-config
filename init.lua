if vim.g.neovide then
  vim.cmd [[ set guifont=DMMono\ Nerd\ Font\ Mono:h11 ]]
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_scroll_animation_length = 0

  vim.g.neovide_remember_window_size = true
  vim.g.neovide_fullscreen = false
  function _G.toggle_full_screen()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end

  vim.api.nvim_set_keymap('n', '<F11>', ':lua toggle_full_screen()<cr>', { silent = true })
end

vim.o.shellquote = ''
vim.o.shellpipe = '|'
vim.o.shellxquote = ''

vim.g.mapleader = ' '
vim.g.lsp_provider = 'nvim'

vim.g.python3_host_prog = '"C:/Windows/python3.exe'

vim.g.nvim_path = '$HOME/.config/nvim/'
vim.g.config_path = vim.g.nvim_path .. "config"
config_path = vim.g.config_path

require('plugins')
require('plugin.editor.config')

vim.g.nvim_path = '$HOME/.config/nvim/'
vim.g.config_path = vim.g.nvim_path .. 'config'

for _, config_file in ipairs({ 'editor' }) do
  vim.g.config_file = config_file
  vim.cmd [[execute 'source ' . g:config_path . '/' . g:config_file . '.vim']]
end

