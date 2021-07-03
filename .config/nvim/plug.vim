function! CocPostInstall(info)
  if a:info.status == 'installed' || a:info.force
    :CocInstall coc-explorer coc-json coc-fzf-preview coc-snippets coc-highlight coc-python coc-rls coc-toml coc-yaml coc-cmake coc-lists coc-vimlsp coc-clangd
  endif
endfunction

call plug#begin('~/.vim/plugged')

" Completion & Languages

"if lsp_provider ==? 'coc'
  Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': function('CocPostInstall')}
  Plug 'jackguo380/vim-lsp-cxx-highlight'
"elseif lsp_provider ==? 'nvim_lsp'
  " Plug 'neovim/nvim-lspconfig'
  " Plug 'glepnir/lspsaga.nvim'
  " Plug 'nvim-lua/completion-nvim'
  " Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  " Plug 'kyazdani42/nvim-web-devicons' " file icons
  " Plug 'kyazdani42/nvim-tree.lua'
"endif
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'liuchengxu/vista.vim'

" Navigation
Plug 'phaazon/hop.nvim'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'

Plug 'junegunn/fzf' ", { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vim-clap' ", { 'do': ':Clap install-binary' }
Plug 'vn-ki/coc-clap'

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'fannheyward/telescope-coc.nvim'
Plug 'Shatur/neovim-session-manager'

"Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python -m chadtree deps'}
Plug 'romgrk/barbar.nvim'
Plug 'tommcdo/vim-exchange'
Plug 'tommcdo/vim-lion'
"Plug 'preservim/nerdcommenter'

Plug 'kana/vim-textobj-user'
Plug 'rhysd/vim-textobj-anyblock' " ib/ab selection



" Themes
" Use private personal configuration of ayu theme
Plug 'git@gitlab.com:luco-bellic/ayu-vim.git', { 'branch': 'personal' }
"Plug 'Luxed/ayu-vim'
"Plug 'frazrepo/vim-rainbow'

" Icons
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
" Plug 'adelarsq/vim-emoji-icon-theme'

" UI
"Plug 'wfxr/minimap.vim'
Plug 'psliwka/vim-smoothie' " or Plug 'yuttie/comfortable-motion.vim'
"Plug 'folke/which-key.nvim'
"Plug 'mhinz/vim-startify'    " Start screen
Plug 'glepnir/dashboard-nvim'
" Plug 'Yggdroot/indentLine'
Plug 'lukas-reineke/indent-blankline.nvim', {'branch': 'lua'}
" Plug 'glepnir/indent-guides.nvim'
Plug 'junegunn/goyo.vim'     " Zen mode
Plug 'folke/zen-mode.nvim'
Plug 'junegunn/limelight.vim'
Plug 'voldikss/vim-floaterm' " Floating terminal
"Plug 'camspiers/animate.vim' " Animation with lens.vim
"Plug 'camspiers/lens.vim'    " Automatic window resize
"
Plug 'onsails/lspkind-nvim' " Pictogram for neovim

Plug 'folke/todo-comments.nvim'
Plug 'folke/trouble.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'luochen1990/rainbow'

"Plug 'itchyny/lightline.vim'
Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}

" Other
Plug 'jceb/vim-orgmode'
Plug 'xolox/vim-misc'
Plug 'moll/vim-bbye'
Plug 'honza/vim-snippets'

call plug#end()

