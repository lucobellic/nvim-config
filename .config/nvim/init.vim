"set runtimepath^=~/.vim runtimepath+=~/.config/nvim
"let &runtimepath.=',~/.config/nvim'
"let &packpath = &runtimepath
"source ~/.vimrc

" TODO
" 1. WIP switch from coc.vim to the following plugin:
"  - completion :
"    - snippets Ultisnips or other
"  - lspsaga :
"    - Line number highlight
"    - Remove icons
"    - Toggle virtual text message error
"    - Find a correct non-exsting preview navigation shortcut
"
" 2. Correct exit from lazygit lspsaga floating terminal
" 3. Add new shortcut for terminal escaping
" 4. Add switch between header/cpp shortcut
" 5. Add several configuration files to easly switch from lspconfig to coc
"
"
" let &shell = has('win32') ? 'powershell' : 'pwsh'
let &shell = 'pwsh'
set shellquote= shellpipe=\| shellxquote=
set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
set shellredir=\|\ Out-File\ -Encoding\ UTF8

"let g:config_path = stdpath('config')
let g:nvim_path    = '$HOME/.config/nvim/'
let g:config_path  = g:nvim_path . 'config'
execute 'source ' . g:nvim_path . '/' . 'plug.vim'

let g:lsp_provider = 'coc'
let g:mapleader    = "\<Space>"

""" Load configuration
lua require('plugins')

let vim_config_files = [
      \ "editor",
      \ "colors",
      \ "keybindings",
      \ "search",
      \ ]

for config_file in g:vim_config_files
  execute 'source ' . g:config_path . '/' . config_file . '.vim'
endfor

let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

