"set GitGutterLineNrHighlightsEnable
"set GitGutterSignsDisable
let g:EasyMotion_smartcase         = 1 " Turn on case-insensitive
let g:EasyMotion_use_smartsign_us  = 1 " Match both '1' and '!'
let g:EasyMotion_off_screen_search = 0 " Do not search outside the screen range
let g:EasyMotion_do_shade          = 1 " Enable shade

" Move to line
nmap <leader>l <Plug>(easymotion-bd-jk)
nmap <leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <leader>j <Plug>(easymotion-bd-w)
nmap <leader>J <Plug>(easymotion-overwin-w)

"let g:EasyMotion_do_mapping = 0 " Disable default mappings
map <leader><leader> <Plug>(easymotion-prefix)
map <leader>s        <Plug>(easymotion-s)

let g:easymotion#is_active = 0
function! EasyMotionCoc() abort
  if EasyMotion#is_active()
    let g:easymotion#is_active = 1
    CocDisable
  else
    if g:easymotion#is_active == 1
      let g:easymotion#is_active = 0
      CocEnable
    endif
  endif
endfunction

if g:lsp_provider ==? 'coc'
  autocmd TextChanged,CursorMoved * call EasyMotionCoc()
end
