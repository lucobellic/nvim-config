-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]
vim.g.nvim_path = '$HOME/.config/nvim/'
vim.g.config_path = vim.g.nvim_path .. "config"

config_path = vim.g.config_path

require('packer').startup({function(use)
  -- Packer manage itself
  use {'wbthomason/packer.nvim', opt = false}

  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'

  require('plugin.lsp').config(use)

  require('plugin.completion').config(use)

  require('plugin.navigation').config(use)
  require('plugin.preview').config(use)
  require('plugin.ui').config(use)
  require('plugin.editor').config(use)

  require('plugin.mappings')

  -- Tasks
  use 'skywind3000/asyncrun.vim'
  use {'skywind3000/asynctasks.vim', after = 'asyncrun.vim'}
  use {'GustavoKatel/telescope-asynctasks.nvim', after = 'asynctasks.vim'}

  -- Debugger
  use {'mfussenegger/nvim-dap'}

  -- Other
  use  'lewis6991/impatient.nvim'
  use  'moll/vim-bbye'  -- Close buffer and window
  use  'xolox/vim-misc'
  use  'honza/vim-snippets'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end,
  config = {max_jobs=10}
})

require('colors') -- Apply coloscheme configuration

-- Workaround to manually source the packer compiled file
-- local packer_compiled = vim.g.nvim_path .. '/plugin/packer_compiled.lua'
-- vim.cmd('luafile'  .. packer_compiled)

