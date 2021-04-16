let g:goyo_width = 120
let g:goyo_height = '90%'
let g:goyo_linenr = 1

"autocmd! User GoyoEnter nested call <SID>goyo_enter()
"autocmd! User GoyoLeave nested call <SID>goyo_leave()
nnoremap <silent> <C-z> :<C-u>Goyo<CR>

"function! s:goyo_enter()
"  if executable('tmux') && strlen($TMUX)
"    silent !tmux set status off
"    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
"  endif
"  set noshowmode
"  set noshowcmd
"  set scrolloff=999
"  let b:coc_diagnostic_disable = 1
"  CocDisable
"  hi link LspCxxHlSymParameter Constant
"  hi link LspCxxHlSymField Todo
"  hi link LspCxxHlGroupMemberVariable Todo
"  hi link ClapPreview Normal
"  hi link ClapDisplay Normal
"  hi link ClapCurrentSelection CursorLine
"  " ...
"endfunction

"function! s:goyo_leave()
"  if executable('tmux') && strlen($TMUX)
"    silent !tmux set status on
"    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
"  endif
"  set showmode
"  set showcmd
"  set scrolloff=5
"  let b:coc_diagnostic_disable = 0
"  CocEnable
"  hi link LspCxxHlSymParameter Constant
"  hi link LspCxxHlSymField Todo
"  hi link LspCxxHlGroupMemberVariable Todo
"  hi link ClapPreview Normal
"  hi link ClapDisplay Normal
"  hi link ClapCurrentSelection CursorLine
"  " ...
"endfunction


