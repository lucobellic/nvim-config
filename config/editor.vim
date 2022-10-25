autocmd BufEnter * silent! :Glcd
" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Tabulation improvement
set wildmode=longest:full,full

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


set noshowmode
set nobackup
set nowritebackup
set notimeout
set nospell
set noswapfile

autocmd FileType cpp setlocal commentstring=//\ %s

let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

