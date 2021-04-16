"let g:clap_no_matches_msg = "¯\\_(ツ)_/¯"
"let g:clap_preview_size = { '*': 5, 'files': 10 }
let g:clap_preview_direction = 'UD' "Upside down preview display
let g:clap_layout = { 'relative': 'editor', 'row': '2%'} " Relative to the whole editor

hi link ClapPreview Normal
hi link ClapDisplay Normal
hi link ClapCurrentSelection CursorLine

nnoremap <silent> <C-p>          :<C-u>:Clap files ++finder=rg --files --follow --hidden<CR>
nnoremap <silent> <leader>mp     :<C-u>:Clap files ++finder=rg --files --follow --hidden<CR>
nnoremap <silent> <leader>my     :<C-u>:Clap yanks<CR>
nnoremap <silent> <leader>mb     :<C-u>:Clap buffers<CR>
nnoremap <silent> <leader>mf     :<C-u>:Clap blines<CR>
nnoremap <silent> <leader>mF     :<C-u>:Rg<CR>
nnoremap <silent> <C-S-f>        :<C-u>:Rg<CR>
nnoremap <silent> <leader>ml     :<C-u>:Clap! lines<CR>
nnoremap <silent> <leader>m'     :<C-u>:Clap! marks<CR>
nnoremap <silent> <leader>ef     :<C-u>:Clap! filer<CR>

