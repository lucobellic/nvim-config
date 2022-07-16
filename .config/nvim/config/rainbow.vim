let g:rainbow_active = 1

let g:rainbow_load_separately = [
    \ [ '*.tex' , [['(', ')'], ['\[', '\]']] ],
    \ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
    \ ]

let g:rainbow_conf = {
    \ 'guifgs' : ['Gold', 'Orchid', 'LightSkyBlue', 'DarkOrange']
\}

