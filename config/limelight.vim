let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_guifg = '#1B2733'


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

nnoremap <silent> <A-z> :call LimelightToggle()<cr>
