autocmd BufEnter * silent! :Glcd
" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Tabulation improvement
set wildmode=longest:full,full

set filetype=1
set noshowmode
set nobackup
set number
set nowritebackup
set noswapfile
set nospell

autocmd FileType cpp setlocal commentstring=//\ %s

let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

