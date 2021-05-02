set termguicolors     " enable true colors support
set background=dark
"set ayucolor="dark"   " for dark version of theme
colorscheme ayu

let g:rainbow_active = 1

" \ [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
let g:rainbow_load_separately = [
    \ [ '*.tex' , [['(', ')'], ['\[', '\]']] ],
    \ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
    \ ]

let g:rainbow_guifgs = ['Gold', 'Orchid', 'LightSkyBlue', 'DarkOrange']

" transparent bg
function! Transparency()
	hi Normal guibg=none ctermbg=none
	hi CursorColumn guibg=none ctermbg=none
	hi CursorLine guibg=none ctermbg=none
	hi CursorLineNr guibg=none ctermbg=none
	hi LineNr guibg=none ctermbg=none
	hi Folded guibg=none ctermbg=none
	hi NonText guibg=none ctermbg=none
	hi SpecialKey guibg=none ctermbg=none
	hi VertSplit guibg=none ctermbg=none
	hi SignColumn guibg=none ctermbg=none
	hi Pmenu guibg=none ctermbg=none
	hi StatusLine guibg=none ctermbg=none
	hi LightlineMiddle_inactive guibg=none ctermbg=none
	hi LightlineMiddle_active guibg=none ctermbg=none
	hi VertSplit guibg=none ctermbg=none
endfunction

" autocmd vimenter * call Transparency()
" autocmd ColorScheme * call Transparency()

hi link LspCxxHlSymParameter Constant
hi link LspCxxHlSymField Todo
