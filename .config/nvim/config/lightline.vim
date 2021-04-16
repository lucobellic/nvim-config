" Use vista.vim to display function
function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction


" Nearest function in statusline
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" ['cocstatus', 'lineinfo']
let g:lightline = {
     \ 'colorscheme': 'ayu',
     \ 'active': {
     \   'left': [ [ 'm', 'paste' ],
     \             [ 'gitbranch' ],
     \             [ 'readonly', 'filename', 'modified' ] ],
     \   'right': [ ['method'] ]
     \ },
     \ 'component_function': {
     \   'gitbranch': 'FugitiveHead',
     \   'method': 'NearestMethodOrFunction',
     \   'm': 'LightMode'
     \ },
     \ }


function! LightMode()
  let l:m = mode()
  return toupper(m)
endfunction

" \   'cocstatus': 'coc#status',
" Use autocmd to force lightline update.
" autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
