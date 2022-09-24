-- paste over currently selected text without yanking it
vim.api.nvim_set_keymap('v', 'p'         , 'p :let @"=@0 | let @*=@0 | let @+=@0<cr>' , {silent = true, noremap = true})
vim.api.nvim_set_keymap('v', 'P'         , 'P :let @"=@0 | let @*=@0 | let @+=@0<cr>' , {silent = true, noremap = true})


vim.api.nvim_set_keymap('n', '<leader>p' , ':<C-u>bo 20split tmp<cr>:terminal<cr>'    , {silent = true, noremap = true})

-- Git
vim.api.nvim_set_keymap('n', '<leader>gc', ':<C-u>Git commit<cr>'                     , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>ga', ':<C-u>Git commit --amend<cr>'             , {silent = true, noremap = true})

vim.api.nvim_set_keymap('n', '<Esc>'     , ':nohl<cr>'                                , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>w' , '<C-w>'                                    , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>wd', ':Bdelete<cr>'                             , {silent = true, noremap = true})


-- Window
vim.api.nvim_set_keymap('n', '<C-left>'  , ':vertical resize +5<cr>'                  , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<C-down>'  , ':resize -5<cr>'                           , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<C-up>'    , ':resize +5<cr>'                           , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<C-right>' , ':vertical resize -5<cr>'                  , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<S-left>'  , '<C-w>h'                                   , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<S-down>'  , '<C-w>j'                                   , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<S-up>'    , '<C-w>k'                                   , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<S-right>' , '<C-w>l'                                   , {silent = true, noremap = true})

-- Escape terminal insert mode and floating terminal
vim.api.nvim_set_keymap('t', '<Esc>'     , '<C-\\><C-n>'                              , {silent = true, noremap = true})

-- Search mapping
vim.api.nvim_set_keymap('n', '<leader>FF', ':<C-u>:Files'                                                         , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fg', ':<C-u>:Rg'                                                            , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<C-S-f>'   , ':<C-u>:Rg'                                                            , {silent = true, noremap=true})

vim.api.nvim_set_keymap('n', '<C-p>'     , '<cmd>Telescope find_files<cr>'                                        , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>'                                        , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>'                                          , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fe', '<cmd>Telescope file_browser<cr>'                                      , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fy', '<cmd>Telescope registers<cr>'                                         , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>y' , '<cmd>Telescope registers<cr>'                                         , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', "<leader>f'", '<cmd>Telescope marks<cr>'                                             , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', "<leader>'" , '<cmd>Telescope marks<cr>'                                             , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>'                                           , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fl', '<cmd>Telescope current_buffer_fuzzy_find<cr>'                         , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>FL', '<cmd>Telescope live_grep<cr>'                                         , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>fw', ":execute 'Telescope grep_string default_text='.expand('<cword>')<cr>" , {silent = true, noremap=true})

-- " From https://github.com/nvim-telescope/telescope.nvim/issues/905#issuecomment-991165992
vim.cmd [[
vnoremap   <silent>   <leader>fw               "sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')"<cr><cr>
]]
-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", {silent = true, noremap=true})
vim.api.nvim_set_keymap('v', '/'         , '"hy/<C-r>h'                                                                           , {silent = false, noremap=true})


-- buffer line mappings
-- Move to previous/next
vim.api.nvim_set_keymap('n', '<C-h>'     , ':BufferPrevious<cr>'                      , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<C-l>'     , ':BufferNext<cr>'                          , {silent = true, noremap = true})

-- Re-order to previous/next
vim.api.nvim_set_keymap('n', '<A-h>'     , ':BufferMovePrevious<cr>'                  , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<A-l>'     , ':BufferMoveNext<cr>'                      , {silent = true, noremap = true})

-- Goto buffer in position...
vim.api.nvim_set_keymap('n', '<leader>1' , ':BufferGoto 1<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>2' , ':BufferGoto 2<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>3' , ':BufferGoto 3<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>4' , ':BufferGoto 4<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>5' , ':BufferGoto 5<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>6' , ':BufferGoto 6<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>7' , ':BufferGoto 7<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>8' , ':BufferGoto 8<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>9' , ':BufferGoto 9<cr>'                        , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<leader>0' , ':BufferLast<cr>'                          , {silent = true, noremap = true})

-- Close buffer
vim.api.nvim_set_keymap('n', '<leader>wd', ':BufferClose<cr>'                         , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<C-q>'     , ':BufferClose<cr>'                         , {silent = true, noremap = true})

-- Magic buffer-picking mode
vim.api.nvim_set_keymap('n', '<C-s>'     , ':BufferPick<cr>'                          , {silent = true, noremap = true})

-- Sort automatically by...
vim.api.nvim_set_keymap('n', '<Space>bd' , ':BufferOrderByDirectory<cr>'              , {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '<Space>bl' , ':BufferOrderByLanguage<cr>'               , {silent = true, noremap = true})

