local opts = { silent = true, noremap = true }

-- paste over currently selected text without yanking it
vim.api.nvim_set_keymap('v', 'p', 'p :let @"=@0 | let @*=@0 | let @+=@0<cr>', opts)
vim.api.nvim_set_keymap('v', 'P', 'P :let @"=@0 | let @*=@0 | let @+=@0<cr>', opts)

local wk_ok, wk = pcall(require, 'which-key')

local telescope_mapping_n = {
    ["<leader>"] = {
        F = {
            name = "find",
            F = { ':<C-u>:Files<cr>', 'Find All File' },
            L = { ":lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", 'Search Workspace' },
        },
        f = {
            name = "find",
            f = { '<cmd>Telescope find_files<cr>', 'Find File' },
            F = { ':<C-u>:Files<cr>', 'Find All File' },
            r = { '<cmd>Telescope oldfiles<cr>', 'Find Recent File' },
            g = { ':<C-u>:Rg<cr>', 'Search Workspace' },
            b = { '<cmd>Telescope buffers<cr>', 'Find Buffer' },
            l = { '<cmd>Telescope current_buffer_fuzzy_find<cr>', 'Search in Buffer' },
            L = { ":lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", 'Search Workspace' },
            m = { '<cmd>Telescope marks<cr>', "Find Marks" },
            y = { '<cmd>Telescope registers<cr>', 'Find Registers' },
            w = { ":execute 'Telescope grep_string default_text='.expand('<cword>')<cr>", 'Find Word' }
        },
    },

}


if wk_ok then
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

vim.api.nvim_set_keymap('n', '<leader>gc', '<cmd>Git commit<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>ga', '<cmd>Git commit --amend<cr>', opts)

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
if wk_ok then
    for i = 0, 9, 1 do
        wk.register({ ["<leader>" .. i] = "which_key_ignore" })
    end
end

-- Close buffer
vim.api.nvim_set_keymap('n', '<C-q>', ':BufferClose<cr>', opts)

-- Magic buffer-picking mode
vim.api.nvim_set_keymap('n', '<C-s>', ':BufferPick<cr>', opts)

-- Sort automatically by...
vim.api.nvim_set_keymap('n', '<Space>bd', ':BufferOrderByDirectory<cr>', opts)
vim.api.nvim_set_keymap('n', '<Space>bl', ':BufferOrderByLanguage<cr>', opts)

-- Outline
vim.api.nvim_set_keymap('n', '<Space>go', ':Lspsaga outline<cr>', opts)

-- Zen mode
vim.api.nvim_set_keymap('n', '<C-z>', ':ZenMode<cr>', opts)


-- Trouble
wk.register({ ['<leader>gt'] = { ':TodoTrouble<cr>', 'Todo Trouble' } })

-- Floaterm
vim.api.nvim_set_keymap('n', '<F7>', ':FloatermToggle!<cr>', opts)
vim.api.nvim_set_keymap('t', '<F7>', '<C-\\><C-n>:FloatermToggle!<cr>', opts)
if wk_ok then
    wk.register({
        ["g;"] = {
            ':<C-u>FloatermNew --height=0.8 --width=0.8 --title=lazygit --name=lazygit lazygit<cr>',
            'Lazygit'
        }
    })
end

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

-- Hop
if wk_ok then
    local hop_mapping = { ["<leader>"] = {
        j = { "<cmd>lua require'hop'.hint_words()<cr>", 'Hop words' },
        J = { "<cmd>lua require'hop'.hint_words({multi_windows = true})<cr>", 'Hop all words' },
        l = { "<cmd>lua require'hop'.hint_lines()<cr>", 'Hop lines' },
        L = { "<cmd>lua require'hop'.hint_lines({multi_windows = true})<cr>", 'Hop all lines' },
        k = { "<cmd>silent lua require'hop'.hint_patterns()<cr>", 'Hop patterns' },
        K = { "<cmd>silent lua require'hop'.hint_patterns({multi_windows = true})<cr>", 'Hop all patterns' },
    } }
    wk.register(hop_mapping, { silent = true, mode = 'n' })
    wk.register(hop_mapping, { silent = true, mode = 'v' })

    -- f/F, t/T
    local hop_reimplement_mapping = {
        f = {"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", 'Hop next char'},
        F = {"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", 'Hop prev char'},
        t = {"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", 'Hop next char'},
        T = {"<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = -1 })<cr>", 'Hop prev char'},
    }
    wk.register(hop_reimplement_mapping, {silent = true, mode = 'n'})
    wk.register(hop_reimplement_mapping, {silent = true, mode = 'v'})
end

-- Diffview
if wk_ok then
    wk.register({ ["<leader>"] = {
        g = {
            d = { ':DiffviewOpen<cr>', 'Diffview Open' },
            q = { ':DiffviewClose<cr>', 'Diffview Close' },
            f = { ':DiffviewFileHistory %<cr>', 'Diffview File History' },
        }
    }, silent = true })
end

vim.keymap.set('n', '<C-b>', '<cmd>:NeoTreeShowToggle<cr>', opts)
-- vim.keymap.set('n', '<C-b>', ':NvimTreeFindFileToggle<cr>', opts)