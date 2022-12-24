-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
end

local packer_ok, packer = pcall(require, 'packer')
if packer_ok then
  packer.startup({ function(use)
    -- Packer manage itself
    use { 'wbthomason/packer.nvim', opt = false }

    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'dstein64/vim-startuptime'

    require('plugin.lsp').config(use)
    require('plugin.completion').config(use)
    require('plugin.navigation').config(use)
    require('plugin.preview').config(use)
    require('plugin.ui').config(use)
    require('plugin.editor').config(use)

    -- Tasks
    use 'skywind3000/asyncrun.vim'
    use { 'skywind3000/asynctasks.vim', after = 'asyncrun.vim' }
    use { 'GustavoKatel/telescope-asynctasks.nvim', after = 'asynctasks.vim' }

    -- Debugger
    use { 'mfussenegger/nvim-dap' }

    -- Other
    use 'lewis6991/impatient.nvim'
    use 'moll/vim-bbye' -- Close buffer and window
    use 'xolox/vim-misc'
    use 'honza/vim-snippets'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
  end,
    config = { max_jobs = 10 }
  })
end

require('colors') -- Apply coloscheme configuration
