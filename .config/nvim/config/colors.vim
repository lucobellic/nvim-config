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

let g:rainbow_conf = {
    \ 'guifgs' : ['Gold', 'Orchid', 'LightSkyBlue', 'DarkOrange']
\}

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


hi link BufferVisible BufferInactive
hi link BufferVisibleIcon BufferInactive
hi link BufferVisibleSign BufferInactive

hi link BufferCurrentMod GitGutterChange
hi link BufferVisibleMod GitGutterChange
hi link BufferInactiveMod GitGutterChange

hi link CocSemVariable Normal
hi link CocSemProperty Todo
hi link CocSemClass Structure
hi link CocSemStorageClass Keyword
hi link CocSemModifier Keyword
hi link CocSemParameter Constant
hi link CocSemKeyword Keyword
hi link CocSemNamespace Regexp


" hi link CocSemNamespace Todo
" hi link CocSemType Todo
" hi link CocSemClass Todo
" hi link CocSemEnum Todo
" hi link CocSemInterface Todo
" hi link CocSemStruct Todo
" hi link CocSemTypeParameter Todo
" hi link CocSemParameter Todo
" hi link CocSemVariable Todo
" hi link CocSemProperty Todo
" hi link CocSemEnumMember Todo
" hi link CocSemEvent Todo
" hi link CocSemFunction Todo
" hi link CocSemMethod Todo
" hi link CocSemMacro Todo
" hi link CocSemKeyword Todo
" hi link CocSemModifier Todo
" hi link CocSemComment Todo
" hi link CocSemString Todo
" hi link CocSemNumber Todo
" hi link CocSemBoolean Todo
" hi link CocSemRegexp Todo
" hi link CocSemOperator Todo
" hi link CocSemDecorator Todo
" hi link CocSemDeprecated Todo

" hi link DiagnosticError TODO
" hi link DiagnosticWarning TODO
" hi link DiagnosticInformation TODO
" hi link DiagnosticHint TODO
