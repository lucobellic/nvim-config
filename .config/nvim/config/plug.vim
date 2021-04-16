function! CocPostInstall(info)
  if a:info.status == 'installed' || a:info.force
    :CocInstall coc-explorer coc-json coc-fzf-preview coc-snippets coc-highlight coc-python coc-rls coc-toml coc-yaml coc-cmake coc-lists coc-vimlsp coc-clangd
  endif
endfunction

call plug#begin('~/.vim/plugged')

" Completion & Languages
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': function('CocPostInstall')}
"Plug 'neovim/nvim-lspconfig'
"Plug 'glepnir/lspsaga.nvim'
"Plug 'nvim-lua/completion-nvim'
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'liuchengxu/vista.vim'

" Navigation
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf' ", { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vim-clap' ", { 'do': ':Clap install-binary' }
"Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python -m chadtree deps'}

" Themes
" Use private personal configuration of ayu theme
Plug 'git@gitlab.com:luco-bellic/ayu-vim.git', { 'branch': 'personal' }
"Plug 'Luxed/ayu-vim'
Plug 'frazrepo/vim-rainbow'
Plug 'jackguo380/vim-lsp-cxx-highlight'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Icons
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'
" Plug 'adelarsq/vim-emoji-icon-theme'

" UI
"Plug 'wfxr/minimap.vim'
Plug 'psliwka/vim-smoothie' " or Plug 'yuttie/comfortable-motion.vim'
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'mhinz/vim-startify'    " Start screen
Plug 'junegunn/goyo.vim'     " Zen mode
Plug 'voldikss/vim-floaterm' " Floating terminal
"Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
"Plug 'camspiers/animate.vim' " Animation with lens.vim
"Plug 'camspiers/lens.vim'    " Automatic window resize
"Plug 'onsails/lspkind-nvim' " Pictogram for neovim


Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'

" Other
Plug 'jceb/vim-orgmode'
Plug 'xolox/vim-misc'
Plug 'moll/vim-bbye'
Plug 'honza/vim-snippets'

call plug#end()

