let g:gitgutter_sign_priority            = 30
let g:gitgutter_sign_allow_clobber       = 0
let g:gitgutter_sign_added               = '|'
let g:gitgutter_sign_removed             = '|'
let g:gitgutter_sign_modified            = '|'
let g:gitgutter_sign_modified_removed    = '|'
let g:gitgutter_show_msg_on_hunk_jumping = 0

hi link GitGutterAddLineNr          GitGutterAdd
hi link GitGutterChangeLineNr       GitGutterChange
hi link GitGutterDeleteLineNr       GitGutterDelete
hi link GitGutterChangeDeleteLineNr GitGutterChangeDelete


nmap <H <Plug>(GitGutterPrevHunk)
nmap >H <Plug>(GitGutterNextHunk)
nmap <Leader>hv <Plug>(GitGutterPreviewHunk)

