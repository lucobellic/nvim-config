let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.7, 'border': 'none', 'highlight': 'Comment' } }

let $FZF_DEFAULT_COMMAND = 'rg --ignore-case --no-ignore --files --hidden --follow'

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--info=inline']}, <bang>0)

command! -bang -nargs=* Rg
			\ call fzf#vim#grep(
			\   'rg --line-number --color=always --smart-case --hidden -- '.shellescape(<q-args>), 0,
			\   fzf#vim#with_preview(), <bang>0)


" Use vim-devicons
let g:fzf_preview_use_dev_icons = 0

" devicons character width
let g:fzf_preview_dev_icon_prefix_string_length = 3

" Devicons can make fzf-preview slow when the number of results is high
" By default icons are disable when number of results is higher that 5000
let g:fzf_preview_dev_icons_limit = 1000

let g:rg_derive_root='true'
