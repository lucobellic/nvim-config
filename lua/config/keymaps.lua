-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local wk = require('which-key')
local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl-shift> hjkl keys
map("n", "<S-left>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<S-down>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<S-up>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<S-right>", "<C-w>l", { desc = "Go to right window", remap = true })

map('c', '<esc>', '<C-c>', { desc = 'Exit insert mode' })
map('n', '<leader>wq', '<C-w>c', { desc = 'Delete window' })
map('n', '<leader>w-', '<C-w>_', { desc = 'Max out the width' })
map('n', '<leader>w|', '<C-w>|', { desc = 'Max out the height' })
map('n', '<leader>wo', '<C-w>o', { desc = 'Close all other windows' })
map('n', '<leader>ws', '<C-w>s', { desc = 'Split window' })
map('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
map('n', '<leader>wx', '<C-w>x', { desc = 'Swap current with next' })
map('n', '<leader>wt', '<C-w>T', { desc = 'Break out into a next tab' })
map('n', '<leader>wT', '<C-w>T', { desc = 'Break out into a next tab' })
map('n', '<leader>ww', '<C-w>p', { desc = 'Other window', remap = true })
map('n', '<leader>wd', '<C-w>c', { desc = 'Delete window', remap = true })
map('n', '<leader>w=', '<C-w>=', { desc = 'Equal high and wide', remap = true })


-- Move Lines
-- TODO: replace by mini plugin
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", opts)
map('v', '/', '"hy/<C-r>h', { desc = 'Search word' })
map({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

-- stylua: ignore start

-- toggle options
map("n", "<leader>uf", require("lazyvim.plugins.lsp.format").toggle, { desc = "Toggle format on Save" })
map("n", "<leader>us", function() Util.toggle("spell") end, { desc = "Toggle Spelling" })
map("n", "<leader>uw", function() Util.toggle("wrap") end, { desc = "Toggle Word Wrap" })
map("n", "<leader>ul", function() Util.toggle_number() end, { desc = "Toggle Line Numbers" })
map("n", "<leader>ua", function() vim.g.minianimate_disable = not vim.g.minianimate_disable end, { desc = "Toggle Mini Animate" })
map('n', '<leader>uS', ':ToggleAutoSave<cr>', { desc = 'Toggle Autosave' })

local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function() Util.toggle("conceallevel", false, { 0, conceallevel }) end,
  { desc = "Toggle Conceal" })
if vim.lsp.inlay_hint then
  map("n", "<leader>uh", function() vim.lsp.inlay_hint(0, nil) end, { desc = "Toggle Inlay Hints" })
end

wk.register({ ['<leader>ut'] = { ':TransparencyToggle<cr>', 'Toggle Transparency' } })
-- map("n", "<leader>ud", Util.toggle_diagnostics, { desc = "Toggle Diagnostics" })
wk.register({
  ['<leader>ud'] = {
    name = 'Toggle Diagnostics',
    d = { Util.toggle_diagnostics, 'Toggle Diagnostics' },
    t = { ':ToggleDiagnosticVirtualText<cr>', 'Toggle Virtual Text' },
    l = { ':ToggleDiagnosticVirtualLines<cr>', 'Toggle Virtual Lines' },
  }
})

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map('n', '<leader>qa', "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

-- Terminal Mappings
map("t", "<esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<S-left>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<S-down>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<S-up>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<S-right>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })

-- tabs
map('n', '<C-k>', ':tabnext<cr>', { desc = 'Tab Next' })
map('n', '<C-j>', ':tabprev<cr>', { desc = 'Tab Prev' })
map('n', 'gn', ':tabnew<cr>', { desc = 'Tab New' })
map('n', 'gq', ':tabclose<cr>', { desc = 'Tab Close' })

-- NOTE: Set <c-f> keymap once again due to configuration issue
vim.keymap.set({ 'n' }, '<C-f>',
  function() require('telescope').extensions.live_grep_args.live_grep_args() end,
  { remap = true, desc = 'Search Workspace' }
)

-- Remap smart-splits to use range
map('n', '<C-left>', require('smart-splits').resize_left, { repeatable = true, desc = 'Resize left' })
map('n', '<C-down>', require('smart-splits').resize_down, { repeatable = true, desc = 'Resize down' })
map('n', '<C-up>', require('smart-splits').resize_up, { repeatable = true, desc = 'Resize up' })
map('n', '<C-right>', require('smart-splits').resize_right, { repeatable = true, desc = 'Resize right' })

map('n', '<leader>a', '<cmd>silent %y+<cr>', { desc = 'Copy all' })

-- Spelling
map('n', '>S', ']s', { repeatable = true, desc = 'Next Spelling' })
map('n', '>s', ']s', { repeatable = true, desc = 'Next Spelling' })
map('n', '<S', '[s', { repeatable = true, desc = 'Prev Spelling' })
map('n', '<s', '[s', { repeatable = true, desc = 'Prev Spelling' })

-- Copilot
wk.register({ ['<leader>cp'] = { ':Copilot panel<cr>', 'Copilot Panel' } })
