call wilder#setup({
      \ 'modes': [':', '/', '?'],
      \ 'next_key': v:false,
      \ 'previous_key': v:false,
      \ 'refect_key': v:false,
      \ 'accept_key': v:false,
      \ 'enable_cmdline_enter': 0
      \})

" Create the WilderAccent highlight
call wilder#set_option('renderer', wilder#popupmenu_renderer({
      \ 'highlighter': wilder#basic_highlighter(),
      \ 'highlights': {
      \   'accent': wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, {'foreground': '#E6B450'}]),
      \ },
      \ 'reverse': 0,
      \ }))

call wilder#set_option('pipeline', [
      \   wilder#branch(
      \     wilder#cmdline_pipeline({
      \       'language': 'python',
      \       'fuzzy': 1,
      \     }),
      \     wilder#python_search_pipeline({
      \       'pattern': wilder#python_fuzzy_pattern(),
      \       'sorter': wilder#python_difflib_sorter(),
      \       'engine': 're',
      \     }),
      \   ),
      \ ])

cnoremap <expr> <Tab> <SID>in_context(0) ? <SID>start_wilder() : '<Tab>'

" Mapping to use both Up/Down arrow and Tab/S-Tab
cnoremap <expr> <Down> <SID>in_context(1) ? wilder#next() : '<Down>'
cnoremap <expr> <Up> <SID>in_context(1) ? wilder#previous() : '<Up>'
cnoremap <expr> <S-Tab> <SID>in_context(1) ? wilder#previous() : '<S-Tab>'

let s:wilder_started = 0
autocmd CmdlineLeave * let s:wilder_started = 0

function! s:start_wilder() abort
  let s:wilder_started = 1
  return wilder#next()
endfunction

function! s:in_context(check_started) abort
  if a:check_started && !s:wilder_started
    return 0
  endif

  return wilder#in_context()
endfunction
