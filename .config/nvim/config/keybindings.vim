nnoremap <silent> <leader>p      :<C-u>bo 20split tmp<CR>:terminal<CR>
nnoremap <silent> <leader>gc     :<C-u>Git commit<CR>
nnoremap <silent> <leader>ga     :<C-u>Git commit --amend<CR>

nnoremap <silent> <C-left>      :vertical resize +5<cr>
nnoremap <silent> <C-up>        :resize +5<cr>
nnoremap <silent> <C-down>      :resize -5<cr>
nnoremap <silent> <C-right>     :vertical resize -5<cr>
nnoremap <silent> <S-left>      <C-w>h
nnoremap <silent> <S-up>        <C-w>k
nnoremap <silent> <S-down>      <C-w>j
nnoremap <silent> <S-right>     <C-w>l

" ----------------- Navigation ------------------ "

nnoremap <silent> <leader>1 1gt
nnoremap <silent> <leader>2 2gt
nnoremap <silent> <leader>3 3gt
nnoremap <silent> <leader>4 4gt
nnoremap <silent> <leader>5 5gt
nnoremap <silent> <leader>6 6gt
nnoremap <silent> <leader>7 7gt
nnoremap <silent> <leader>8 8gt
nnoremap <silent> <leader>9 9gt

nnoremap <silent> <leader>th :tabprev<CR>
nnoremap <silent> <leader>tl :tabnext<CR>
nnoremap          <leader>tt :tabedit<Space>
nnoremap <silent> <leader>tn :tabnew<CR>
nnoremap          <leader>tm :tabm<Space>
nnoremap <silent> <leader>tq :tabclose<CR>

" Move to line
nmap <leader>l <Plug>(easymotion-bd-jk)
nmap <leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <leader>j <Plug>(easymotion-bd-w)
nmap <leader>J <Plug>(easymotion-overwin-w)

nmap <H <Plug>(GitGutterPrevHunk)
nmap >H <Plug>(GitGutterNextHunk)
nmap <Leader>hv <Plug>(GitGutterPreviewHunk)

nnoremap <silent> <Esc>       :nohl<CR>
map               <leader>w   <C-w>
nnoremap <silent> <leader>wd  :Bdelete<CR>

" Escape terminal insert mode and floating terminal
"tnoremap <silent> <S-Esc> <C-\><C-n>

"let g:EasyMotion_do_mapping = 0 " Disable default mappings
map <leader><leader> <Plug>(easymotion-prefix)
map <leader>s        <Plug>(easymotion-s)

"set GitGutterLineNrHighlightsEnable
"set GitGutterSignsDisable
let g:EasyMotion_smartcase         = 1 " Turn on case-insensitive
let g:EasyMotion_use_smartsign_us  = 1 " Match both '1' and '!'
let g:EasyMotion_off_screen_search = 0 " Do not search outside the screen range
let g:EasyMotion_do_shade          = 1 " Enable shade

