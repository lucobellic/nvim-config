set clipboard+=unnamedplus
let mapleader="\<SPACE>"
set number
set signcolumn=yes:1
set cursorline
set noswapfile
set autoread
set autowrite
set autowriteall
"autocmd TextChanged,TextChangedI <buffer> silent! write
set spell
set noshowmode " Disable -- INSERT -- and similar
set wrap! " Disable wrapping
" invalid
set wmw=0 " Minimum window width
set wmh=0 " Minimum window height
set ignorecase

set hidden
set nobackup
set nowritebackup
set cmdheight=1
set updatetime=4000

autocmd BufEnter * silent! :Glcd

" Tabulation improvement
set wildmode=longest:full,full
set wildmenu

" tab/space behavior
" with tpope/sleuth usage
if get(g:, '_has_set_default_indent_settings', 0) == 0
  " Indenting defaults (does not override vim-sleuth's indenting detection)
  " Defaults to 2 spaces for most filetypes
  " Set the indenting level to 2 spaces for the following file types.
  " autocmd FileType typescript,javascript,jsx,tsx,css,html,ruby,elixir,kotlin,vim,plantuml
        " \ setlocal expandtab tabstop=2 shiftwidth=2
  set expandtab
  set tabstop=2
  set shiftwidth=2
  let g:_has_set_default_indent_settings = 1
endif

" set expandtab
" set shiftwidth=2
" set tabstop=2
" set smarttab

set list
set showbreak=↪
set listchars=tab:-\ ,trail:·,extends:⟩,precedes:⟨
set fillchars=vert:\|

set notimeout
"set timeoutlen=500

let g:lion_squeeze_spaces = 1

let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

