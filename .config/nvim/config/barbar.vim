" NOTE: If barbar's option dict isn't created yet, create it
let bufferline = get(g:, 'bufferline', {})

" Enable/disable animations
let bufferline.animation = v:true

" Enable/disable auto-hiding the tab bar when there is a single buffer
let bufferline.auto_hide = v:true

" Enable/disable current/total tabpages indicator (top right corner)
let bufferline.tabpages = v:true

let bufferline.closable = v:false
let bufferline.clickable = v:false
let bufferline.icons = 'numbers'

" Configure icons on the bufferline.
let bufferline.icon_separator_active = '|'
let bufferline.icon_separator_inactive = ''
let bufferline.icon_close_tab = ''
let bufferline.icon_close_tab_modified = ''

" Sets the maximum padding width with which to surround each tab
let bufferline.maximum_padding = 1

" Move to previous/next
nnoremap <silent>    <C-h> :BufferPrevious<CR>
nnoremap <silent>    <C-l> :BufferNext<CR>

" Re-order to previous/next
nnoremap <silent>    <A-h> :BufferMovePrevious<CR>
nnoremap <silent>    <A-l> :BufferMoveNext<CR>
" Goto buffer in position...
nnoremap <silent>    <leader>1 :BufferGoto 1<CR>
nnoremap <silent>    <leader>2 :BufferGoto 2<CR>
nnoremap <silent>    <leader>3 :BufferGoto 3<CR>
nnoremap <silent>    <leader>4 :BufferGoto 4<CR>
nnoremap <silent>    <leader>5 :BufferGoto 5<CR>
nnoremap <silent>    <leader>6 :BufferGoto 6<CR>
nnoremap <silent>    <leader>7 :BufferGoto 7<CR>
nnoremap <silent>    <leader>8 :BufferGoto 8<CR>
nnoremap <silent>    <leader>9 :BufferGoto 9<CR>
nnoremap <silent>    <leader>0 :BufferLast<CR>
" Close buffer
nnoremap <silent>   <leader>wd :BufferClose<CR>
nnoremap <silent>   <C-d>      :BufferClose<CR>
nnoremap <silent>   <leader>bd :BufferClose<CR>
" Wipeout buffer
"                          :BufferWipeout<CR>
" Close commands
"                          :BufferCloseAllButCurrent<CR>
"                          :BufferCloseBuffersLeft<CR>
"                          :BufferCloseBuffersRight<CR>
" Magic buffer-picking mode
nnoremap <silent> <C-s>    :BufferPick<CR>
" Sort automatically by...
nnoremap <silent> <Space>bd :BufferOrderByDirectory<CR>
nnoremap <silent> <Space>bl :BufferOrderByLanguage<CR>
