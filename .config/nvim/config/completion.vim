let g:completion_enable_auto_popup = 0
let g:completion_matching_smart_case = 1
let g:completion_enable_snippet = 'UltiSnips'

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

imap <tab> <Plug>(completion_smart_tab)
imap <s-tab> <Plug>(completion_smart_s_tab)

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> <Plug>(completion_smart_tab)
else
  inoremap <silent><expr> <c-@> <Plug>(completion_smart_tab)
endif

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c


