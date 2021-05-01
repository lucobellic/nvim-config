set runtimepath^=~/.vim runtimepath+=~/.config/nvim
let &packpath = &runtimepath
source ~/.vimrc

" TODO
" 1. WIP switch from coc.vim to the following plugin:
"  - completion :
"    - snippets Ultisnips or other
"  - lspsaga :
"    - Line number highlight
"    - Remove icons
"    - Toggle virtual text message error
"    - Find a correct non-exsting preview navigation shortcut
"  - treesitter :
"    - highlight parameter reference (variable parameter in function body do not have the correct highlight)
".
" 2. Correct exit from lazygit lspsaga floating terminal
" 3. Add new shortcut for terminal escaping
" 4. Add switch between header/cpp shortcut
" 5. Add several configuration files to easly switch from lspconfig to coc
".

"let g:config_path = stdpath('config')
let g:nvim_path = '$HOME/.config/nvim/'
let g:config_path = g:nvim_path . 'config'
execute 'source ' . g:nvim_path . '/' . 'plug.vim'

let g:mapleader = "\<Space>"
"let g:maplocalleader = ','
let g:lsp_provider = 'coc' " 'nvim_lsp'

""" Load configuration

if lsp_provider ==? 'coc'
    execute 'source ' . g:config_path . '/' . 'coc.vim'
else
  " TODO with lua
    execute 'source ' . g:config_path . '/' . 'completion.vim'
    " lspsage.lua
    " lspconfig.lua
    " treesitter.lua
endif

let config_files = [
      \ "editor",
      \ "easymotion",
      \ "clap",
      \ "colors",
      \ "floaterm",
      \ "fzf",
      \ "gitgutter",
      \ "goyo",
      \ "lightline",
      \ "startify",
      \ "vista",
      \ "whichkey",
      \ "keybindings"
      \ ]

for config_file in g:config_files
    execute 'source ' . g:config_path . '/' . config_file . '.vim'
endfor

let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

