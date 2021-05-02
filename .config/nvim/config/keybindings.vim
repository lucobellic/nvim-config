nnoremap <silent> <leader>p      :<C-u>bo 20split tmp<CR>:terminal<CR>
nnoremap <silent> <leader>gc     :<C-u>Git commit<CR>
nnoremap <silent> <leader>ga     :<C-u>Git commit --amend<CR>

nnoremap <silent> <Esc>       :nohl<CR>
map               <leader>w   <C-w>
nnoremap <silent> <leader>wd  :Bdelete<CR>


" ----------------- Navigation ------------------ "

nnoremap <silent> <C-left>      :vertical resize +5<cr>
nnoremap <silent> <C-up>        :resize +5<cr>
nnoremap <silent> <C-down>      :resize -5<cr>
nnoremap <silent> <C-right>     :vertical resize -5<cr>
nnoremap <silent> <S-left>      <C-w>h
nnoremap <silent> <S-up>        <C-w>k
nnoremap <silent> <S-down>      <C-w>j
nnoremap <silent> <S-right>     <C-w>l


" nnoremap <silent> <leader>1 1gt
" nnoremap <silent> <leader>2 2gt
" nnoremap <silent> <leader>3 3gt
" nnoremap <silent> <leader>4 4gt
" nnoremap <silent> <leader>5 5gt
" nnoremap <silent> <leader>6 6gt
" nnoremap <silent> <leader>7 7gt
" nnoremap <silent> <leader>8 8gt
" nnoremap <silent> <leader>9 9gt

nnoremap <silent> <leader>th :tabprev<CR>
nnoremap <silent> <leader>tl :tabnext<CR>
nnoremap          <leader>tt :tabedit<Space>
nnoremap <silent> <leader>tn :tabnew<CR>
nnoremap          <leader>tm :tabm<Space>
nnoremap <silent> <leader>tq :tabclose<CR>

" Escape terminal insert mode and floating terminal
tnoremap <silent> <Esc> <C-\><C-n>

