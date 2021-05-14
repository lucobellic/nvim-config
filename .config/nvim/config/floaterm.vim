let g:floaterm_autoclose = 1 "Close only if the job exits normally
let g:floaterm_borderchars = '       ' " (top, right, bottom, left, topleft, topright, botright, botleft)
nnoremap <silent> <F7> :FloatermToggle!<CR>
tnoremap <silent> <F7> <C-\><C-n>:FloatermToggle!<CR>
nnoremap <silent> g;   :<C-u>FloatermNew --height=0.8 --width=0.8 --name=lazygit lazygit<CR>

