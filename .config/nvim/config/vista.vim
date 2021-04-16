let g:vista_default_executive = g:lsp_provider
let g:vista_sidebar_width = 50
let g:vista_echo_cursor_startegy = 'scroll'
let g:vista_echo_cursor = 0
let g:vista_keep_fzf_colors = 1
let g:vista_enable_centering_jump = 0

nnoremap <silent> <leader>mo     :<C-u>Vista!!<CR>
nnoremap <silent> <leader>mO     :<C-u>:Clap tags<CR>
nnoremap <silent> <leader>o      :<C-u>Vista focus<CR>

