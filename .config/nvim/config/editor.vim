set clipboard+=unnamedplus
let mapleader="\<SPACE>"
set number
set signcolumn=yes:1
set cursorline
set noswapfile
set autoread
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
set updatetime=100

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

autocmd BufEnter * silent! :Glcd

" Tabulation improvement
set wildmode=longest:full,full
set wildmenu

" tab/space behavior
set tabstop=2
set expandtab
set shiftwidth=2
set smarttab

set list
set showbreak=↪
set listchars=tab:-\ ,trail:·,extends:⟩,precedes:⟨
set fillchars=vert:\|

nnoremap <silent> <leader>  :WhichKey '<Space>'<CR>
nnoremap <silent> <leader>  :<c-u>WhichKey '<Space>'<CR>
"nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
set timeoutlen=500

