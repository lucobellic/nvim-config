local opts = { silent = true, noremap = true }

-- paste over currently selected text without yanking it
vim.api.nvim_set_keymap('v', 'p', 'p :let @"=@0 | let @*=@0 | let @+=@0<cr>', opts)
vim.api.nvim_set_keymap('v', 'P', 'P :let @"=@0 | let @*=@0 | let @+=@0<cr>', opts)

local wk_ok, wk = pcall(require, 'which-key')

if wk_ok then
  wk.register({
    ['<leader>y'] = { ':YankyRingHistory<cr>', 'Yank History' },
  })
end

local telescope_mapping_n = {
  ["<leader>"] = {
    F = {
      name = "find",
      F = { ':<C-u>:Files<cr>', 'Find All File' },
      L = { ":lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", 'Search Workspace' },
    },
    f = {
      name = "find",
      b = { '<cmd>Telescope buffers<cr>', 'Find Buffer' },
      e = { ":lua require('telescope.builtin').symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} }<cr>",
        'Find Symbols' },
      f = { '<cmd>Telescope find_files<cr>', 'Find File' },
      F = { ':<C-u>:Files<cr>', 'Find All File' },
      g = { ':<C-u>:Rg<cr>', 'Search Workspace' },
      k = { ":lua require('telescope.builtin').symbols{ sources = {'kaomoji'} }<cr>", 'Find Symbols' },
      l = { '<cmd>Telescope current_buffer_fuzzy_find<cr>', 'Search in Buffer' },
      L = { ":lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", 'Search Workspace' },
      m = { '<cmd>Telescope marks<cr>', "Find Marks" },
      r = { '<cmd>Telescope oldfiles<cr>', 'Find Recent File' },
      w = { ":execute 'Telescope grep_string default_text='.expand('<cword>')<cr>", 'Find Word' },
      y = { '<cmd>Telescope yank_history<cr>', 'Yank History' },
    },
  },
}

if wk_ok then
  wk.register(telescope_mapping_n)
  wk.register({ ['<C-p>'] = { '<cmd>Telescope find_files<cr>', "Find files" } })
  wk.register({
    ['<C-f>'] = { ":lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", 'Search Workspace' } })

  -- TODO: try to add visual mode for Find Word in whickkey
  -- " From https://github.com/nvim-telescope/telescope.nvim/issues/905#issuecomment-991165992
  vim.cmd [[
  vnoremap <silent> <leader>fw "sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')"<cr><cr>
  ]]
end


vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>silent %y+<cr>', opts)
vim.api.nvim_set_keymap('n', '<c-s>', ':w<cr>', opts)

-- ChatGPT

if wk_ok then
  wk.register({
    ["<leader>c"] = {
      name = "complete",
      e = { function() require('chatgpt').edit_with_instructions() end, "ChatGPT edit with instructions" },
    }
  }, { mode = "v" })

  wk.register({
    ["<leader>c"] = {
      g = { ":ChatGPT<cr>", "ChatGPT" }
    }
  }, { mode = "n" })
end

-- Git
vim.api.nvim_set_keymap('n', '<leader>gc', '<cmd>Git commit<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>ga', '<cmd>Git commit --amend<cr>', opts)

vim.api.nvim_set_keymap('n', '<Esc>', ':nohl<cr><Esc>', opts)
vim.api.nvim_set_keymap('n', '<leader>w', '<C-w>', { noremap = false })

-- Spelling
vim.api.nvim_set_keymap('n', '>S', ']s', opts)
vim.api.nvim_set_keymap('n', '>s', ']s', opts)
vim.api.nvim_set_keymap('n', '<S', '[s', opts)
vim.api.nvim_set_keymap('n', '<s', '[s', opts)


-- Window
vim.api.nvim_set_keymap('n', '<C-left>', ':vertical resize +5<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-down>', ':resize -5<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-up>', ':resize +5<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-right>', ':vertical resize -5<cr>', opts)
vim.api.nvim_set_keymap('n', '<S-left>', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<S-down>', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<S-up>', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<S-right>', '<C-w>l', opts)

vim.api.nvim_set_keymap('n', '<C-w>z', ':WindowsMaximize<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-w>_', ':WindowsMaximizeVertically<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-w>|', ':WindowsMaximizeHorizontally<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-w>=', ':WindowsEqualize<cr>', opts)

-- Escape terminal insert mode and floating terminal
vim.api.nvim_set_keymap('t', '<Esc>', '(&filetype == "fzf") ? "<Esc>" : "<C-\\><C-n>"',
  { silent = true, noremap = true, expr = true })

-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", opts)
vim.api.nvim_set_keymap('v', '/', '"hy/<C-r>h', { silent = false, noremap = true })


-- local bufferline_ok, _ = pcall(require, 'bufferline')
local bufferline_ok = false
local barbar_ok = true
if bufferline_ok then
  -- Move to previous/next
  vim.api.nvim_set_keymap('n', '<C-h>', ':BufferLineCyclePrev<cr>', opts)
  vim.api.nvim_set_keymap('n', '<C-l>', ':BufferLineCycleNext<cr>', opts)

  -- Re-order to previous/next
  vim.api.nvim_set_keymap('n', '<A-h>', ':BufferLineMovePrev<cr>', opts)
  vim.api.nvim_set_keymap('n', '<A-l>', ':BufferLineMoveNext<cr>', opts)
  vim.api.nvim_set_keymap('n', '<A-p>', ':BufferLineTogglePin<cr>', opts)

  -- Close buffer
  vim.api.nvim_set_keymap('n', '<C-q>', ':Bdelete<cr>', opts)

  -- Magic buffer-picking mode
  vim.api.nvim_set_keymap('n', '<C-/>', ':BufferLinePick<cr>', opts)
  vim.api.nvim_set_keymap('n', '<A-i>', ':BufferLinePickClose<cr>', opts)
elseif barbar_ok then
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
  vim.api.nvim_set_keymap('n', '<C-/>', ':BufferPick<cr>', opts)
end

-- Sort automatically by...
vim.api.nvim_set_keymap('n', '<Space>bd', ':BufferOrderByDirectory<cr>', opts)
vim.api.nvim_set_keymap('n', '<Space>bl', ':BufferOrderByLanguage<cr>', opts)

-- Outline
vim.api.nvim_set_keymap('n', '<Space>go', ':SymbolsOutline<cr>', opts)

-- Zen mode
vim.api.nvim_set_keymap('n', '<C-z>', ':ZenMode<cr>', opts)

-- Limelight
vim.api.nvim_set_keymap('n', '<A-z>', ':LimelightToggle<cr>', opts)

-- Tab navigation
if wk_ok then
  wk.register({
    ["<C-k>"] = { ':tabnext<cr>', 'Next Tab' },
    ["<C-j>"] = { ':tabprev<cr>', 'Previous Tab' },
    g = {
      n = { ':tabnew<cr>', 'New Tab' },
      N = { ':tabclose<cr>', 'Close Tab' },
    }
  })
end

-- Trouble
if wk_ok then
  wk.register({
    ["<leader>"] = {
      t = {
        c = { ':TroubleClose<cr>', 'Trouble close' },
        d = { ':Trouble document_diagnostics<cr>', 'Trouble diagnostics' },
        f = { ':TodoTelescope<cr>', 'Todo telescope' },
        l = {
          d = { ':Trouble lsp_definitions<cr>', 'Trouble lsp definitions' },
          i = { ':Trouble lsp_implementations<cr>', 'Trouble lsp implementations' },
          r = { ':Trouble lsp_references<cr>', 'Trouble lsp references' },
          t = { ':Trouble lsp_type_definitions<cr>', 'Trouble lsp type definitions' }
        },
        q = { ':Trouble quickfix<cr>', 'Trouble quickfix' },
        r = { ':TroubleRefresh<cr>', 'Trouble refresh' },
        t = { ':Trouble todo<cr>', 'Trouble todo' },
      }
    }
  }, opts)
end


-- Diagnostics
if wk_ok then
  wk.register({
    ["<leader>"] = {
      d = {
        name = 'diagnostics',
        t = { ':ToggleDiagnosticVirtualText<cr>', 'Toggle virtual text' },
        l = { ':ToggleDiagnosticVirtualLines<cr>', 'Toggle virtual lines' },
      }
    }
  }, opts)
end


-- Floaterm
vim.api.nvim_set_keymap('n', '<F7>', ':FloatermToggle<cr>', opts)
vim.api.nvim_set_keymap('t', '<F7>', '<C-\\><C-n>:FloatermToggle<cr>', opts)
-- if wk_ok then
--   wk.register({
--     ["g;"] = {
--       ':<C-u>FloatermNew --height=0.8 --width=0.8 --title=lazygit($1/$2) --name=lazygit lazygit<cr>',
--       'Lazygit'
--     }
--   })
-- end

-- Hop
if wk_ok then
  local hop_mapping = {
    ["<leader>"] = {
      j = { "<cmd>lua require'hop'.hint_words()<cr>", 'Hop words' },
      J = { "<cmd>lua require'hop'.hint_words({multi_windows = true})<cr>", 'Hop all words' },
      l = { "<cmd>lua require'hop'.hint_lines()<cr>", 'Hop lines' },
      L = { "<cmd>lua require'hop'.hint_lines({multi_windows = true})<cr>", 'Hop all lines' },
      k = { "<cmd>silent lua require'hop'.hint_patterns()<cr>", 'Hop patterns' },
      K = { "<cmd>silent lua require'hop'.hint_patterns({multi_windows = true})<cr>", 'Hop all patterns' },
    }
  }
  wk.register(hop_mapping, { silent = true, mode = 'n' })
  wk.register(hop_mapping, { silent = true, mode = 'v' })

  -- f/F, t/T
  local overwrite_navigation = false
  if overwrite_navigation then
    local hop_reimplement_mapping = {
      f = {
        "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>",
        'Hop next char' },
      F = {
        "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>",
        'Hop prev char' },
      t = {
        "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<cr>",
        'Hop next char' },
      T = {
        "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<cr>",
        'Hop prev char' },
    }
    wk.register(hop_reimplement_mapping, { silent = true, mode = 'n' })
    wk.register(hop_reimplement_mapping, { silent = true, mode = 'v' })
  end
end

-- Git
if wk_ok then
  local diffview_mapping = {
    ["<leader>"] = {
      g = {
        name = "git",
        g = { ':DiffviewOpen<cr>', 'Diffview Open' },
        q = { ':DiffviewClose<cr>', 'Diffview Close' },
        f = { ':DiffviewFileHistory %<cr>', 'Diffview File History' },
        d = { ':DiffviewOpen origin/develop...HEAD<cr>', 'Diffview origin/develop...HEAD' },
      }
    },
    silent = true
  }
  wk.register(diffview_mapping, { silent = true, mode = 'n' })
  wk.register(diffview_mapping, { silent = true, mode = 'v' })
end
vim.keymap.set('n', '<C-b>', '<cmd>:NeoTreeShowToggle<cr>', opts)

-- search current word
vim.keymap.set({ "n" }, "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>")
vim.keymap.set({ "v" }, "<leader>s", "<esc>:lua require('spectre').open_visual()<CR>")

-- search in current file
vim.keymap.set({ "n", "x" }, "<leader>sp", "<cmd>lua require('spectre').open_file_search()<cr>")

vim.keymap.set({ "n" }, "<leader>p", ":ToggleTerm<cr>")
vim.keymap.set({ "n" }, "<leader>P", ":ToggleTermToggleAll<cr>")

-- Copilot
if wk_ok then
  wk.register({ ['<leader>cp'] = { ':Copilot panel<cr>', 'Copilot Panel' } })
end

-- Colorscheme
if wk_ok then
  wk.register({ ['<leader>ut'] = { ':TransparencyToggle<cr>', 'Toggle Transparency' } })
end

-- Documentaion generation
if wk_ok then
  wk.register(
    {
      ['<leader>n'] = {
        name = 'documentation',
        f = { ':lua require("neogen").generate()<cr>', 'Document' },
        c = { ":lua require('neogen').generate({ type = 'class' })<CR>", 'Document class' }
      }
    }
  )
end
