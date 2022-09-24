-- paste over currently selected text without yanking it
vim.api.nvim_set_keymap('v', 'p'         , 'p :let @"=@0 | let @*=@0 | let @+=@0<cr>'                             , {silent = true, noremap = true})
vim.api.nvim_set_keymap('v', 'P'         , 'P :let @"=@0 | let @*=@0 | let @+=@0<cr>'                             , {silent = true, noremap = true})


vim.api.nvim_set_keymap('n', '<leader>p' , ':<C-u>bo 20split tmp<cr>:terminal<cr>'                                , {silent = true, noremap = true})

-- Git
vim.api.nvim_set_keymap('n', '<leader>gc', ':<C-u>Git commit<cr>'                                                 , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>ga', ':<C-u>Git commit --amend<cr>'                                         , {silent = true, noremap=true})

vim.api.nvim_set_keymap('n', '<Esc>'     , ':nohl<cr>'                                                            , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>w' , '<C-w>'                                                                , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<leader>wd', ':Bdelete<cr>'                                                         , {silent = true, noremap=true})


-- Window
vim.api.nvim_set_keymap('n', '<C-left>'  , ':vertical resize +5<cr>'                                              , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<C-down>'  , ':resize -5<cr>'                                                       , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<C-up>'    , ':resize +5<cr>'                                                       , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<C-right>' , ':vertical resize -5<cr>'                                              , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-left>'  , '<C-w>h'                                                               , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-down>'  , '<C-w>j'                                                               , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-up>'    , '<C-w>k'                                                               , {silent = true, noremap=true})
vim.api.nvim_set_keymap('n', '<S-right>' , '<C-w>l'                                                               , {silent = true, noremap=true})

-- Escape terminal insert mode and floating terminal
vim.api.nvim_set_keymap('t', '<Esc>'     , '<C-\\><C-n'                                                           , {silent = true, noremap=true})

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


