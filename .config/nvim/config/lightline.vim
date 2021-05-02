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
     \             [ 'readonly', 'filename', 'modified' ]],
     \   'right': [ ['method'] ]
     \ },
     \ 'component_function': {
     \   'gitbranch': 'FugitiveHead',
     \   'method': 'NearestMethodOrFunction',
     \   'm': 'LightMode',
     \   'cocstatus': 'coc#status',
     \ },
     \ }

function! StatusDiagnostic() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return '' | endif
  let msgs = []
  if get(info, 'error', 0)
    call add(msgs, 'E' . info['error'])
  endif
  if get(info, 'warning', 0)
    call add(msgs, 'W' . info['warning'])
  endif
  return join(msgs, ' ') . ' ' . get(g:, 'coc_status', '')
endfunction

function! CoCErrorDiagnostic()
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info) | return 'Ok' | endif
  if get(info, 'error', 0) | return  '🔥' . inf['error'] | endif
  return join(msgs, ' ')
endfunction

function! LightMode()
  let l:m = mode()
  return toupper(m)
endfunction

" Use autocmd to force lightline update.
autocmd User CocStatusChange, CocDiagnosticChange call lightline#update()

