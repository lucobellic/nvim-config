let g:fzf_layout = { 'window': { 'width': 0.6, 'height': 0.5, 'relative': v:false, 'yoffset': 0.0, 'border': 'none', 'highlight': 'Comment' } }
let g:fzf_preview_window = ['down:50%:hidden:noborder', 'ctrl-/']

let $FZF_DEFAULT_COMMAND = 'rg --smart-case --no-ignore --ignore-exclude --files --hidden --follow'

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)

command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --line-number --smart-case --hidden --no-ignore --ignore-exclude -- '.shellescape(<q-args>), 0,
      \   fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)

command! -bang -nargs=* RgFull
      \ call fzf#vim#grep(
      \   'rg --line-number --smart-case --hidden --no-ignore -- '.shellescape(<q-args>), 0,
      \   fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)


" Use vim-devicons
let g:fzf_preview_use_dev_icons = 1

" devicons character width
let g:fzf_preview_dev_icon_prefix_string_length = 3

" Devicons can make fzf-preview slow when the number of results is high
" By default icons are disable when number of results is higher that 5000
let g:fzf_preview_dev_icons_limit = 100

let g:rg_derive_root='true'

let g:fzf_colors =
      \ {
      \ 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Normal'],
      \ 'fg+':     ['fg', 'Normal', 'Normal', 'Normal'],
      \ 'bg+':     ['bg', 'Normal', 'Normal', 'Normal'],
      \ 'hl+':     ['fg', 'Normal'],
      \ 'query':   ['fg', 'Normal'],
      \ 'gutter':  ['bg', 'Normal'],
      \ 'info':    ['fg', 'Normal'],
      \ 'border':  ['fg', 'Normal'],
      \ 'prompt':  ['fg', 'Normal'],
      \ 'pointer': ['fg', 'Normal'],
      \ 'marker':  ['fg', 'Normal'],
      \ 'spinner': ['fg', 'Normal'],
      \ 'header':  ['fg', 'Normal'] }

