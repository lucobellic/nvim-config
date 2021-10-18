let g:floaterm_autoclose = 0 "Close only if the job exits normally
let g:floaterm_borderchars = '       ' " (top, right, bottom, left, topleft, topright, botright, botleft)
let g:floaterm_autoinsert = v:false
nnoremap <silent> <F7> :FloatermToggle!<CR>
tnoremap <silent> <F7> <C-\><C-n>:FloatermToggle!<CR>
nnoremap <silent> g;   :<C-u>FloatermNew --height=0.8 --width=0.8 --name=lazygit lazygit<CR>

autocmd FileType floaterm nnoremap <silent> <buffer> <C-l> :FloatermNext<CR>
autocmd FileType floaterm tnoremap <silent> <buffer> <C-l> <C-\><C-n>:FloatermNext<CR>

autocmd FileType floaterm nnoremap <silent> <buffer> <C-h> :FloatermPrev<CR>
autocmd FileType floaterm tnoremap <silent> <buffer> <C-h> <C-\><C-n>:FloatermPrev<CR>

autocmd FileType floaterm nnoremap <silent> <buffer> <C-t> :FloatermNew<CR>
autocmd FileType floaterm tnoremap <silent> <buffer> <C-t> <C-\><C-n>:FloatermNew<CR>

