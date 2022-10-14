local opts = {silent = true, noremap = true}

-- paste over currently selected text without yanking it
vim.api.nvim_set_keymap('v', 'p'         , 'p :let @"=@0 | let @*=@0 | let @+=@0<cr>' , opts)
vim.api.nvim_set_keymap('v', 'P'         , 'P :let @"=@0 | let @*=@0 | let @+=@0<cr>' , opts)


vim.api.nvim_set_keymap('n', '<leader>p' , ':<C-u>bo 20split tmp<cr>:terminal<cr>'    , opts)

-- Git
vim.api.nvim_set_keymap('n', '<leader>gc', ':<C-u>Git commit<cr>'                     , opts)
vim.api.nvim_set_keymap('n', '<leader>ga', ':<C-u>Git commit --amend<cr>'             , opts)

vim.api.nvim_set_keymap('n', '<Esc>'     , ':nohl<cr>'                                , opts)
vim.api.nvim_set_keymap('n', '<leader>w' , '<C-w>'                                    , opts)
vim.api.nvim_set_keymap('n', '<leader>wd', ':Bdelete<cr>'                             , opts)


-- Window
vim.api.nvim_set_keymap('n', '<C-left>'  , ':vertical resize +5<cr>'                  , opts)
vim.api.nvim_set_keymap('n', '<C-down>'  , ':resize -5<cr>'                           , opts)
vim.api.nvim_set_keymap('n', '<C-up>'    , ':resize +5<cr>'                           , opts)
vim.api.nvim_set_keymap('n', '<C-right>' , ':vertical resize -5<cr>'                  , opts)
vim.api.nvim_set_keymap('n', '<S-left>'  , '<C-w>h'                                   , opts)
vim.api.nvim_set_keymap('n', '<S-down>'  , '<C-w>j'                                   , opts)
vim.api.nvim_set_keymap('n', '<S-up>'    , '<C-w>k'                                   , opts)
vim.api.nvim_set_keymap('n', '<S-right>' , '<C-w>l'                                   , opts)

-- Escape terminal insert mode and floating terminal
vim.api.nvim_set_keymap('t', '<Esc>'     , '<C-\\><C-n>'                              , opts)

-- Search mapping
vim.api.nvim_set_keymap('n', '<leader>FF', ':<C-u>:Files'                                                         , opts)
vim.api.nvim_set_keymap('n', '<leader>fg', ':<C-u>:Rg'                                                            , opts)
vim.api.nvim_set_keymap('n', '<C-S-f>'   , ':<C-u>:Rg'                                                            , opts)

vim.api.nvim_set_keymap('n', '<C-p>'     , '<cmd>Telescope find_files<cr>'                                        , opts)
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>'                                        , opts)
vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>'                                          , opts)
vim.api.nvim_set_keymap('n', '<leader>fe', '<cmd>Telescope file_browser<cr>'                                      , opts)
vim.api.nvim_set_keymap('n', '<leader>fy', '<cmd>Telescope registers<cr>'                                         , opts)
vim.api.nvim_set_keymap('n', '<leader>y' , '<cmd>Telescope registers<cr>'                                         , opts)
vim.api.nvim_set_keymap('n', "<leader>f'", '<cmd>Telescope marks<cr>'                                             , opts)
vim.api.nvim_set_keymap('n', "<leader>'" , '<cmd>Telescope marks<cr>'                                             , opts)
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>'                                           , opts)
vim.api.nvim_set_keymap('n', '<leader>fl', '<cmd>Telescope current_buffer_fuzzy_find<cr>'                         , opts)
vim.api.nvim_set_keymap('n', '<leader>FL', '<cmd>Telescope live_grep<cr>'                                         , opts)
vim.api.nvim_set_keymap('n', '<leader>fw', ":execute 'Telescope grep_string default_text='.expand('<cword>')<cr>" , opts)

-- " From https://github.com/nvim-telescope/telescope.nvim/issues/905#issuecomment-991165992
vim.cmd [[
vnoremap   <silent>   <leader>fw               "sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')"<cr><cr>
]]
-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", opts)
vim.api.nvim_set_keymap('v', '/' , '"hy/<C-r>h' , {silent = false, noremap=true})


-- buffer line mappings
-- Move to previous/next
vim.api.nvim_set_keymap('n', '<C-h>'     , ':BufferPrevious<cr>'         , opts)
vim.api.nvim_set_keymap('n', '<C-l>'     , ':BufferNext<cr>'             , opts)

-- Re-order to previous/next
vim.api.nvim_set_keymap('n', '<A-h>'     , ':BufferMovePrevious<cr>'     , opts)
vim.api.nvim_set_keymap('n', '<A-l>'     , ':BufferMoveNext<cr>'         , opts)
vim.api.nvim_set_keymap('n', '<A-p>'     , ':BufferPin<cr>'              , opts)

-- Goto buffer in position...
vim.api.nvim_set_keymap('n', '<leader>1' , ':BufferGoto 1<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>2' , ':BufferGoto 2<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>3' , ':BufferGoto 3<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>4' , ':BufferGoto 4<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>5' , ':BufferGoto 5<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>6' , ':BufferGoto 6<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>7' , ':BufferGoto 7<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>8' , ':BufferGoto 8<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>9' , ':BufferGoto 9<cr>'           , opts)
vim.api.nvim_set_keymap('n', '<leader>0' , ':BufferLast<cr>'             , opts)

-- Close buffer
vim.api.nvim_set_keymap('n', '<leader>wd', ':BufferClose<cr>'            , opts)
vim.api.nvim_set_keymap('n', '<C-q>'     , ':BufferClose<cr>'            , opts)

-- Magic buffer-picking mode
vim.api.nvim_set_keymap('n', '<C-s>'     , ':BufferPick<cr>'             , opts)

-- Sort automatically by...
vim.api.nvim_set_keymap('n', '<Space>bd' , ':BufferOrderByDirectory<cr>' , opts)
vim.api.nvim_set_keymap('n', '<Space>bl' , ':BufferOrderByLanguage<cr>'  , opts)

-- Zen mode
vim.api.nvim_set_keymap('n', '<C-z>', ':ZenMode<cr>', opts)


-- Floaterm

vim.api.nvim_set_keymap('n', '<F7>' , ':FloatermToggle!<cr>'                                                 , opts)
vim.api.nvim_set_keymap('t', '<F7>' , '<C-\\><C-n>:FloatermToggle!<cr>'                                      , opts)
vim.api.nvim_set_keymap('n', 'g;'   , ':<C-u>FloatermNew --height=0.8 --width=0.8 --name=lazygit lazygit<cr>', opts)

vim.api.nvim_create_autocmd("FileType", {
    pattern = 'floaterm',
    callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', '<C-l>', ':FloatermNext<CR>'           , opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', '<C-\\><C-n>:FloatermNext<CR>', opts)

        vim.api.nvim_buf_set_keymap(0, 'n', '<C-h>', ':FloatermPrev<CR>'           , opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

        vim.api.nvim_buf_set_keymap(0, 'n', '<C-t>', ':FloatermNew<CR>'            , opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-t>', '<C-\\><C-n>:FloatermNew<CR>' , opts)
    end
})

