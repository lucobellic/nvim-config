vim.api.nvim_exec([[
    augroup MyColors
    autocmd!
    autocmd ColorScheme * hi link LspCxxHlSymParameter Constant
                      \ | hi link LspCxxHlSymField Todo

                      \ | hi link BufferVisible BufferInactive
                      \ | hi link BufferVisibleIcon BufferInactive
                      \ | hi link BufferVisibleSign BufferInactive

                      \ | hi link BufferCurrentMod GitGutterChange
                      \ | hi link BufferVisibleMod GitGutterChange
                      \ | hi link BufferInactiveMod GitGutterChange

                      \ | hi link CocSemVariable Normal
                      \ | hi link CocSemProperty Todo
                      \ | hi link CocSemClass Structure
                      \ | hi link CocSemStorageClass Keyword
                      \ | hi link CocSemModifier Keyword
                      \ | hi link CocSemParameter Constant
                      \ | hi link CocSemKeyword Keyword
    augroup END
]], true)


