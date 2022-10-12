-- vim.cmd[[
--     hi link LspCxxHlSymParameter Constant
--     hi link LspCxxHlSymField Todo
--     hi link BufferVisible BufferInactive
--     hi link BufferVisibleIcon BufferInactive
--     hi link BufferVisibleSign BufferInactive
--     hi link BufferCurrentMod GitGutterChange
--     hi link BufferVisibleMod GitGutterChange
--     hi link BufferInactiveMod GitGutterChange
--     hi link CocSemVariable Normal
--     hi link CocSemProperty Todo
--     hi link CocSemClass Structure
--     hi link CocSemStorageClass Keyword
--     hi link CocSemModifier Keyword
--     hi link CocSemParameter Constant
--     hi link CocSemKeyword Keyword
--     hi link CocSemNamespace Regexp
--     hi HopNextKey guifg=#FF8F40
--     hi HopNextKey1 guifg=#59C2FF
--     hi HopNextKey2 guifg=#C2D94C
--     hi CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
--     hi CmpItemAbbrMatch guibg=NONE guifg=#569CD6
--     hi CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
--     hi CmpItemKindVariable guibg=NONE guifg=#9CDCFE
--     hi CmpItemKindInterface guibg=NONE guifg=#9CDCFE
--     hi CmpItemKindText guibg=NONE guifg=#9CDCFE
--     hi CmpItemKindFunction guibg=NONE guifg=#C586C0
--     hi CmpItemKindMethod guibg=NONE guifg=#C586C0
--     hi CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
--     hi CmpItemKindProperty guibg=NONE guifg=#D4D4D4
--     hi CmpItemKindUnit guibg=NONE guifg=#D4D4D4
-- ]]

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
                      \ | hi link CocSemNamespace Regexp
                      \ | hi HopNextKey guifg=#FF8F40
                      \ | hi HopNextKey1 guifg=#59C2FF
                      \ | hi HopNextKey2 guifg=#C2D94C
                      \ | hi CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080
                      \ | hi CmpItemAbbrMatch guibg=NONE guifg=#569CD6
                      \ | hi CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6
                      \ | hi CmpItemKindVariable guibg=NONE guifg=#9CDCFE
                      \ | hi CmpItemKindInterface guibg=NONE guifg=#9CDCFE
                      \ | hi CmpItemKindText guibg=NONE guifg=#9CDCFE
                      \ | hi CmpItemKindFunction guibg=NONE guifg=#C586C0
                      \ | hi CmpItemKindMethod guibg=NONE guifg=#C586C0
                      \ | hi CmpItemKindKeyword guibg=NONE guifg=#D4D4D4
                      \ | hi CmpItemKindProperty guibg=NONE guifg=#D4D4D4
                      \ | hi CmpItemKindUnit guibg=NONE guifg=#D4D4D4
    augroup END
]], true)


