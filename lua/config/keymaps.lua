-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local util = require("lazyvim.util")
local opts = { silent = true, noremap = true }

-- Removed default keymaps
vim.keymap.del('n', '<leader>ud')
vim.keymap.del('n', '<leader>gg')
vim.keymap.del('n', '<leader>gG')

local wk_ok, wk = pcall(require, 'which-key')

-- NOTE: Set <c-f> keymap once again due to configuration issue
vim.keymap.set(
  'n',
  '<C-f>',
  function() require('telescope').extensions.live_grep_args.live_grep_args() end,
  { desc = 'Search Workspace' }
)

-- Toggle
vim.keymap.set("n", "<leader>ub", ':Gitsigns toggle_current_line_blame<cr>', { desc = "Toggle Line Blame" })
wk.register({
  ['<leader>ud'] = {
    name = 'Toggle Diagnostics',
    d = { util.toggle_diagnostics, 'Toggle Diagnostics' },
    t = { ':ToggleDiagnosticVirtualText<cr>', 'Toggle Virtual Text' },
    l = { ':ToggleDiagnosticVirtualLines<cr>', 'Toggle Virtual Lines' },
  }
})

vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>silent %y+<cr>', opts)
vim.keymap.set('n', '<leader>qa', '<leader>qq', { remap = true, desc = 'Quit all' })

vim.api.nvim_set_keymap('c', '<esc>', '<C-c>', opts)
vim.api.nvim_set_keymap('t', '<esc>', '<C-\\><C-n>', opts)
vim.api.nvim_set_keymap('n', '<leader>w', '<C-w>', { noremap = false })

-- Spelling
vim.api.nvim_set_keymap('n', '>S', ']s', opts)
vim.api.nvim_set_keymap('n', '>s', ']s', opts)
vim.api.nvim_set_keymap('n', '<S', '[s', opts)
vim.api.nvim_set_keymap('n', '<s', '[s', opts)


-- Window
vim.keymap.set('n', '<C-left>', require('smart-splits').resize_left, { desc = 'Resize left' })
vim.keymap.set('n', '<C-down>', require('smart-splits').resize_down, { desc = 'Resize down' })
vim.keymap.set('n', '<C-up>', require('smart-splits').resize_up, { desc = 'Resize up' })
vim.keymap.set('n', '<C-right>', require('smart-splits').resize_right, { desc = 'Resize right' })
-- moving between splits
vim.keymap.set('n', '<S-left>', require('smart-splits').move_cursor_left, { desc = 'Move cursor left' })
vim.keymap.set('n', '<S-down>', require('smart-splits').move_cursor_down, { desc = 'Move cursor down' })
vim.keymap.set('n', '<S-up>', require('smart-splits').move_cursor_up, { desc = 'Move cursor up' })
vim.keymap.set('n', '<S-right>', require('smart-splits').move_cursor_right, { desc = 'Move cursor right' })
-- swap windows
vim.keymap.set('n', '<A-H>', require('smart-splits').swap_buf_left, { desc = 'Swap buffer left' })
vim.keymap.set('n', '<A-J>', require('smart-splits').swap_buf_down, { desc = 'Swap buffer down' })
vim.keymap.set('n', '<A-K>', require('smart-splits').swap_buf_up, { desc = 'Swap buffer up' })
vim.keymap.set('n', '<A-L>', require('smart-splits').swap_buf_right, { desc = 'Swap buffer right' })

vim.api.nvim_set_keymap('n', '<C-w>z', ':WindowsMaximize<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-w>_', ':WindowsMaximizeVertically<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-w>|', ':WindowsMaximizeHorizontally<cr>', opts)
vim.api.nvim_set_keymap('n', '<C-w>=', ':WindowsEqualize<cr>', opts)

-- Escape terminal insert mode and floating terminal
vim.api.nvim_set_keymap('t', '<Esc>', '(&filetype == "fzf") ? "<Esc>" : "<C-\\><C-n>"',
  { silent = true, noremap = true, expr = true })

-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", opts)
vim.api.nvim_set_keymap('v', '/', '"hy/<C-r>h', { silent = false, noremap = true })

-- Outline
vim.api.nvim_set_keymap('n', '<Space>go', ':SymbolsOutline<cr>', opts)

-- Tab navigation
if wk_ok then
  wk.register({
    ["<C-k>"] = { ':tabnext<cr>', 'Next Tab' },
    ["<C-j>"] = { ':tabprev<cr>', 'Previous Tab' },
    g = {
      n = { ':tabnew<cr>', 'New Tab' },
      q = { ':tabclose<cr>', 'Close Tab' },
    }
  })
end

vim.keymap.set('n', '<C-b>', '<cmd>Neotree toggle reveal_force_cwd<cr>', opts)

-- search current word
vim.keymap.set({ "n" }, "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>")
vim.keymap.set({ "v" }, "<leader>s", "<esc>:lua require('spectre').open_visual()<CR>")

-- search in current file
vim.keymap.set({ "n", "x" }, "<leader>sp", "<cmd>lua require('spectre').open_file_search()<cr>")

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

-- Session
if wk_ok then
  wk.register({
    ['<leader>q'] = {
      name = 'session',
      -- restore the session for the current directory
      r    = { ':lua require("persistence").load()<cr>', 'Restore session' },
      -- restore the last session
      l    = { ':lua require("persistence").load({ last = true })<cr>', 'Load last session' },
      -- stop Persistence => session won't be saved on exit
      d    = { ':lua require("persistence").stop()<cr>', 'Stop session' },
      -- load saved sessions
      s    = { ':PersistenceLoadSession<cr>', 'Load session' },
    }
  })
end

-- Refactoring
if wk_ok then
  -- Remaps for the refactoring operations currently offered by the plugin
  local visual_refactoring = {
    ['<leader>r'] = {
      name = 'refactoring',
      e = {
        [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]],
        'Extract Function'
      },
      f = {
        [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
        'Extract Function To File'
      },
      v = {
        [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]],
        'Extract Variable'
      },
      i = {
        [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
        'Inline Variable'
      },
      -- prompt for a refactor to apply when the remap is triggered
      r = {
        ":lua require('refactoring').select_refactor()<CR>",
        'Select Refactor'
      },
      -- remap to open the Telescope refactoring menu in visual mode
      t = {
        "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
        'Telescope Refactor'
      },
    }
  }

  local normal_refactoring = {
    ['<leader>r'] = {
      -- Extract block doesn't need visual mode
      b = {
        b = {
          [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]],
          'Extract Block'
        },
        f = {
          [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]],
          'Extract Block To File'
        }
      },
      -- Inline variable can also pick up the identifier currently under the cursor without visual mode
      i = {
        [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],
        'Inline Variable'
      }
    }
  }

  wk.register(visual_refactoring, { mode = 'v', noremap = true, silent = true, expr = false })
  wk.register(normal_refactoring, { mode = 'n', noremap = true, silent = true, expr = false })
end
