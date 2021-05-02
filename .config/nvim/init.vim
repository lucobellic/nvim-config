"set runtimepath^=~/.vim runtimepath+=~/.config/nvim
let &runtimepath.=',~/.config/nvim'
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
let g:lsp_provider = 'coc'
" let g:lsp_provider = 'nvim_lsp'

""" Load configuration

if g:lsp_provider ==? 'coc'
    execute 'source ' . g:config_path . '/' . 'coc.vim'
elseif g:lsp_provider ==? 'nvim_lsp'
    execute 'source ' . g:config_path . '/' . 'completion.vim'
    lua require('lsp')
    lua require('highlight')
endif

let vim_config_files = [
      \ "editor",
      \ "colors",
      \ "keybindings",
      \ "barbar",
      \ "easymotion",
      \ "clap",
      \ "floaterm",
      \ "fzf",
      \ "gitgutter",
      \ "goyo",
      \ "startify",
      \ "vista",
      \ ]

for config_file in g:vim_config_files
  execute 'source ' . g:config_path . '/' . config_file . '.vim'
endfor


let lua_config_files = [
      \ 'statusline',
      \ 'mapping',
      \]

for config_file in g:lua_config_files
  execute "lua require('" . config_file . "')"
endfor

let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

