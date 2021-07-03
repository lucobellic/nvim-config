let g:goyo_width = '50%'
let g:goyo_height = '90%'
let g:goyo_linenr = 1

" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
"let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
"let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#1B2733'

"autocmd! User GoyoEnter nested call <SID>goyo_enter()
"autocmd! User GoyoLeave nested call <SID>goyo_leave()
" nnoremap <silent> <C-z> :<C-u>Goyo<CR>
let s:enabled = v:false
function! LimelightToggle()
	if s:enabled
		let s:enabled = v:false
		Limelight!
	else
		Limelight
		let s:enabled = v:true
	endif
endfunction

nnoremap <silent> <C-x> :call LimelightToggle()<cr>

function! s:goyo_enter()
  "  if executable('tmux') && strlen($TMUX)
  "    silent !tmux set status off
  "    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  "  endif
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
  setlocal statusline=\
  "  let b:coc_diagnostic_disable = 1
  "  CocDisable
  "  hi link LspCxxHlSymParameter Constant
  "  hi link LspCxxHlSymField Todo
  "  hi link LspCxxHlGroupMemberVariable Todo
  "  hi link ClapPreview Normal
  "  hi link ClapDisplay Normal
  "  hi link ClapCurrentSelection CursorLine
  "  " ...
endfunction

function! s:goyo_leave()
  "  if executable('tmux') && strlen($TMUX)
  "    silent !tmux set status on
  "    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  "  endif
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
  "  let b:coc_diagnostic_disable = 0
  "  CocEnable
  "  hi link LspCxxHlSymParameter Constant
  "  hi link LspCxxHlSymField Todo
  "  hi link LspCxxHlGroupMembmelightToggle()
	"  erVariable Todo
  "  hi link ClapPreview Normal
  "  hi link ClapDisplay Normal
  "  hi link ClapCurrentSelection CursorLine
  "  " ...
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

