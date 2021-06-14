"let g:clap_no_matches_msg = "¯\\_(ツ)_/¯"
"let g:clap_preview_size = { '*': 5, 'files': 10 }
let g:clap_preview_direction = 'UD' "Upside down preview display
let g:clap_layout = { 'relative': 'editor', 'row': '2%'} " Relative to the whole editor

hi link ClapPreview Normal
hi link ClapDisplay Normal
hi link ClapCurrentSelection CursorLine

" nnoremap <silent>   <C-p>                    :<C-u>:Clap files ++finder=rg --files --smart-case --follow                     <CR>
" nnoremap <silent>   <leader>mp               :<C-u>:Clap files ++finder=rg --files --smart-case --follow --hidden --no-ignore<CR>
" nnoremap <leader>fh <cmd>Telescope help_tags <cr>

nnoremap   <silent>   <leader>FF               :<C-u>:Files                                                                   <CR>
nnoremap   <silent>   <leader>ff               <cmd>Telescope find_files                                                      <cr>
nnoremap   <silent>   <C-p>                    <cmd>Telescope find_files                                                      <cr>

nnoremap   <silent>   <leader>fr               <cmd>Telescope oldfiles                                                        <cr>
" nnoremap <silent>   <C-p>                    :<C-u>:Files                                                                   <CR>
" nnoremap <silent>   <C-p>                    :<C-u>:Clap files ++finder=rg --files --smart-case --follow                    <CR>

nnoremap   <silent>   <leader>fe               <cmd>Telescope file_browser                                                    <cr>
" nnoremap <silent>   <leader>fe               :<C-u>:Clap! filer                                                             <CR>
"

nnoremap   <silent>   <leader>fy               <cmd>Telescope registers                                                       <cr>
nnoremap   <silent>   <leader>y                <cmd>Telescope registers                                                       <cr>
" nnoremap <silent>   <leader>my               :<C-u>:Clap yanks                                                              <CR>
nnoremap   <silent>   <leader>fb               <cmd>Telescope buffers                                                         <cr>
" nnoremap <silent>   <leader>fb               :<C-u>:Clap buffers                                                            <CR>

" nnoremap <silent>   <leader>mf               <C-u>:Clap blines                                                              <CR>
nnoremap   <silent>   <leader>fg               :<C-u>:Rg                                                                      <CR>
nnoremap   <silent>   <C-S-f>                  :<C-u>:Rg                                                                      <CR>


nnoremap   <silent>   <leader>fl               <cmd>Telescope current_buffer_fuzzy_find                                       <cr>
" nnoremap <silent>   <leader>fl               :<C-u>:Clap! lines                                                             <CR>

" nnoremap <silent>   <leader>f'               :<C-u>:Clap! marks                                                             <CR>
nnoremap   <silent>   <leader>f'               <cmd>Telescope marks                                                           <cr>
nnoremap   <silent>   <leader>'                <cmd>Telescope marks                                                           <cr>

