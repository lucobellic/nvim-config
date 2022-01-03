-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer  manage itself
  use {'wbthomason/packer.nvim', opt = false}
  use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}
  use {'andymass/vim-matchup', event = 'VimEnter'} -- Better matchup '%' usage

  -- Completion & Languages
  use {'neoclide/coc.nvim',
    branch = 'release',
    disable = false,
    run = ':CocInstall coc-explorer coc-json coc-fzf-preview coc-snippets coc-highlight coc-python coc-rls coc-toml coc-yaml coc-cmake coc-lists coc-vimlsp coc-clangd coc-pyright'
  }
  use 'jackguo380/vim-lsp-cxx-highlight'

  use 'liuchengxu/vista.vim'

  use {'neovim/nvim-lspconfig', disable = true}
  use {'glepnir/lspsaga.nvim', disable = true}
  use {'nvim-lua/completion-nvim', disable = true}

  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'rust-lang/rust.vim'
  use 'cespare/vim-toml'

  -- Navigation
  use  'phaazon/hop.nvim'
  use  'tpope/vim-sensible'
  use  'tpope/vim-surround'
  use  'tpope/vim-commentary'
  use  'tpope/vim-fugitive'
  use  'tpope/vim-sleuth'

  use {'junegunn/fzf', run = 'fzf#install()'}
  use  'junegunn/fzf.vim'
  use {'liuchengxu/vim-clap', run = ':Clap install-binary'}
  use  'vn-ki/coc-clap'

  -- Tasks
  use  'skywind3000/asynctasks.vim'
  use  'skywind3000/asyncrun.vim'
  use  'GustavoKatel/telescope-asynctasks.nvim'

  -- Telescope
  use  'nvim-lua/popup.nvim'
  use  'nvim-lua/plenary.nvim'
  use  'nvim-telescope/telescope.nvim'
  use  'fannheyward/telescope-coc.nvim'
  use  'Shatur/neovim-session-manager'


  use  'romgrk/barbar.nvim'
  use  'tommcdo/vim-exchange'
  use  'tommcdo/vim-lion'

  use  'kana/vim-textobj-user'
  use  'rhysd/vim-textobj-anyblock'   -- vib/vab selection

  -- Themes
  -- Use private personal configuration of ayu theme
  -- use {'git@gitlab.com:luco-bellic/ayu-vim.git', branch = 'personal' }
  -- use {'Luxed/ayu-vim'} -- Maintained ayu theme

  -- Icons
  use  'kyazdani42/nvim-web-devicons'

  -- UI
  use 'glepnir/galaxyline.nvim'
  use  {'lewis6991/gitsigns.nvim', config = 'gitsigns-config.lua'}

  use  'psliwka/vim-smoothie'    -- or Plug 'yuttie/comfortable-motion.vim'
  use  'glepnir/dashboard-nvim'  -- Start screen
  use  'lukas-reineke/indent-blankline.nvim'
  use  'folke/zen-mode.nvim'
  use  'junegunn/limelight.vim'  -- Highlight paragraph
  use  'voldikss/vim-floaterm'  -- Floating terminal
  use  'onsails/lspkind-nvim'   -- Pictogram for neovim

  use  'folke/todo-comments.nvim'
  use  'folke/trouble.nvim'  -- Super nice trouble plugin
  use  'luochen1990/rainbow'  -- Color brackets


  -- Other
  use  'jceb/vim-orgmode'
  use  'xolox/vim-misc'
  use  'moll/vim-bbye'  -- Close buffer and window
  use  'honza/vim-snippets'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
