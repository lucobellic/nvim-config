local opts = { silent = true, noremap = true }

-- paste over currently selected text without yanking it
vim.api.nvim_set_keymap('v', 'p', 'p :let @"=@0 | let @*=@0 | let @+=@0<cr>', opts)
vim.api.nvim_set_keymap('v', 'P', 'P :let @"=@0 | let @*=@0 | let @+=@0<cr>', opts)

local wk = require("which-key")

local telescope_mapping_n = {
    ["<leader>"] = {
        F = {
            name = "find",
            F = { ':<C-u>:Files<cr>', 'Find All File' },
            L = { '<cmd>Telescope live_grep<cr>', 'Search Workspace' },
        },
        f = {
            name = "find",
            f = { '<cmd>Telescope find_files<cr>', 'Find File' },
            F = { ':<C-u>:Files<cr>', 'Find All File' },
            r = { '<cmd>Telescope oldfiles<cr>', 'Find Recent File' },
            g = { ':<C-u>:Rg<cr>', 'Search Workspace' },
            b = { '<cmd>Telescope buffers<cr>', 'Find Buffer' },
            l = { '<cmd>Telescope current_buffer_fuzzy_find<cr>', 'Search in Buffer' },
            L = { '<cmd>Telescope live_grep<cr>', 'Search Workspace' },
            m = { '<cmd>Telescope marks<cr>', "Find Marks" },
            y = { '<cmd>Telescope registers<cr>', 'Find Registers' },
            w = { ":execute 'Telescope grep_string default_text='.expand('<cword>')<cr>", 'Find Word' }
        },
    },

}


if packer_plugins and packer_plugins['telescope.nvim'] then
    wk.register(telescope_mapping_n)
    wk.register({ ['<C-p>'] = { '<cmd>Telescope find_files<cr>', "Find files" } })

    -- TODO: try to add visual mode for Find Word in whickkey
    -- " From https://github.com/nvim-telescope/telescope.nvim/issues/905#issuecomment-991165992
    vim.cmd [[
    vnoremap <silent> <leader>fw "sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')"<cr><cr>
    ]]
end


vim.api.nvim_set_keymap('n', '<leader>p', ':<C-u>bo 20split tmp<cr>:terminal<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>silent %y+<cr>', opts)

-- Git
if packer_plugins and packer_plugins['vim-fugitive'] then
    vim.api.nvim_set_keymap('n', '<leader>gc', '<cmd>Git commit<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>ga', '<cmd>Git commit --amend<cr>', opts)
end

vim.api.nvim_set_keymap('n', '<Esc>', ':nohl<cr><Esc>', opts)
vim.api.nvim_set_keymap('n', '<leader>w', '<C-w>', { noremap = false })


-- Window
vim.api.nvim_set_keymap('n', '<C-left>', ':vertical resize +5<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-down>', ':resize -5<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-up>', ':resize +5<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-right>', ':vertical resize -5<cr>', opts)
vim.api.nvim_set_keymap('n', '<S-left>', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<S-down>', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<S-up>', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<S-right>', '<C-w>l', opts)

-- Escape terminal insert mode and floating terminal
vim.api.nvim_set_keymap('t', '<Esc>', '(&filetype == "fzf") ? "<Esc>" : "<C-\\><C-n>"',
    { silent = true, noremap = true, expr = true })

-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", opts)
vim.api.nvim_set_keymap('v', '/', '"hy/<C-r>h', { silent = false, noremap = true })


if packer_plugins and packer_plugins['barbar.nvim'] then
    -- barbar buffer line mappings
    -- Move to previous/next
    vim.api.nvim_set_keymap('n', '<C-h>', ':BufferPrevious<cr>', opts)
    vim.api.nvim_set_keymap('n', '<C-l>', ':BufferNext<cr>', opts)

    -- Re-order to previous/next
    vim.api.nvim_set_keymap('n', '<A-h>', ':BufferMovePrevious<cr>', opts)
    vim.api.nvim_set_keymap('n', '<A-l>', ':BufferMoveNext<cr>', opts)
    vim.api.nvim_set_keymap('n', '<A-p>', ':BufferPin<cr>', opts)

    -- Goto buffer in position...
    vim.api.nvim_set_keymap('n', '<leader>1', ':BufferGoto 1<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>2', ':BufferGoto 2<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>3', ':BufferGoto 3<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>4', ':BufferGoto 4<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>5', ':BufferGoto 5<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>6', ':BufferGoto 6<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>7', ':BufferGoto 7<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>8', ':BufferGoto 8<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>9', ':BufferGoto 9<cr>', opts)
    vim.api.nvim_set_keymap('n', '<leader>0', ':BufferLast<cr>', opts)

    -- Hide BufferGoto
    for i = 0, 9, 1 do
        wk.register({["<leader>" .. i] = "which_key_ignore"})
    end

    -- Close buffer
    vim.api.nvim_set_keymap('n', '<C-q>', ':BufferClose<cr>', opts)

    -- Magic buffer-picking mode
    vim.api.nvim_set_keymap('n', '<C-s>', ':BufferPick<cr>', opts)

    -- Sort automatically by...
    vim.api.nvim_set_keymap('n', '<Space>bd', ':BufferOrderByDirectory<cr>', opts)
    vim.api.nvim_set_keymap('n', '<Space>bl', ':BufferOrderByLanguage<cr>', opts)
end

-- Outline
if packer_plugins and packer_plugins['lspsaga.nvim'] then
    vim.api.nvim_set_keymap('n', '<Space>go', ':Lspsaga outline<cr>', opts)
end

-- Zen mode
if packer_plugins and packer_plugins['zen-mode.nvim'] then
    vim.api.nvim_set_keymap('n', '<C-z>', ':ZenMode<cr>', opts)
end


-- Trouble
if packer_plugins and packer_plugins['todo-comments.nvim'] then
    wk.register({ ['<leader>gt'] = { ':TodoTrouble<cr>', 'Todo Trouble' } })
end

-- Floaterm
if packer_plugins and packer_plugins['vim-floaterm'] then
    vim.api.nvim_set_keymap('n', '<F7>', ':FloatermToggle!<cr>', opts)
    vim.api.nvim_set_keymap('t', '<F7>', '<C-\\><C-n>:FloatermToggle!<cr>', opts)
    vim.api.nvim_set_keymap('n', 'g;', ':<C-u>FloatermNew --height=0.8 --width=0.8 --title=lazygit --name=lazygit lazygit<cr>', opts)

    vim.api.nvim_create_autocmd("FileType", {
        pattern = 'floaterm',
        callback = function()
            vim.api.nvim_buf_set_keymap(0, 'n', '<C-q>', ':FloatermKill<CR>', opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-q>', '<C-\\><C-n>:FloatermKill<CR>', opts)

            vim.api.nvim_buf_set_keymap(0, 'n', '<C-l>', ':FloatermNext<CR>', opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', '<C-\\><C-n>:FloatermNext<CR>', opts)

            vim.api.nvim_buf_set_keymap(0, 'n', '<C-h>', ':FloatermPrev<CR>', opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

            vim.api.nvim_buf_set_keymap(0, 'n', '<C-t>', ':FloatermNew<CR>', opts)
            vim.api.nvim_buf_set_keymap(0, 't', '<C-t>', '<C-\\><C-n>:FloatermNew<CR>', opts)
        end
    })
end

-- Hop
if packer_plugins and packer_plugins['hop.nvim'] then
    vim.api.nvim_set_keymap('n', '<leader>j', "<cmd>lua require'hop'.hint_words()<cr>", {})
    vim.api.nvim_set_keymap('v', '<leader>j', "<cmd>lua require'hop'.hint_words()<cr>", {})
    vim.api.nvim_set_keymap('n', '<leader>J', "<cmd>lua require'hop'.hint_words({multi_windows = true})<cr>", {})
    vim.api.nvim_set_keymap('v', '<leader>J', "<cmd>lua require'hop'.hint_words({multi_windows = true})<cr>", {})

    vim.api.nvim_set_keymap('n', '<leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", {})
    vim.api.nvim_set_keymap('v', '<leader>l', "<cmd>lua require'hop'.hint_lines()<cr>", {})
    vim.api.nvim_set_keymap('n', '<leader>L', "<cmd>lua require'hop'.hint_lines({multi_windows = true})<cr>", {})
    vim.api.nvim_set_keymap('v', '<leader>L', "<cmd>lua require'hop'.hint_lines({multi_windows = true})<cr>", {})

    vim.api.nvim_set_keymap('n', '<leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", {})
    vim.api.nvim_set_keymap('v', '<leader>s', "<cmd>lua require'hop'.hint_char1()<cr>", {})
    vim.api.nvim_set_keymap('n', '<leader>S', "<cmd>lua require'hop'.hint_char1({multi_windows = true})<cr>", {})
    vim.api.nvim_set_keymap('v', '<leader>S', "<cmd>lua require'hop'.hint_char1({multi_windows = true})<cr>", {})
end
