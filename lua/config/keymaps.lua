-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require('lazyvim.util')
local wk_ok, wk = pcall(require, 'which-key')

local function map(mode, lhs, rhs, opts)
  local keys = require('lazy.core.handler').handlers.keys
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

-- vim.api.nvim_set_keymap('v', '<leader>fw', "\"sy:Telescope live_grep default_text=<C-r>=substitute(substitute(escape(substitute(@s, '\\', '\\\\\\', 'g'), ' '), '\n', '', 'g'), '/', '\\/', 'g')\"<cr><cr>", opts)
map('v', '/', '"hy/<C-r>h', { desc = 'Search word' })
map({ 'n', 'x' }, 'gw', '*N', { desc = 'Search word under cursor' })

-- save file
map({ 'i', 'v', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
-- Search and replace word under cursor
-- map('v', 'r', '"hy/<C-r>h', { desc = 'Search word' })
map(
  'n',
  '<leader>rw',
  function() return ':%s/' .. vim.fn.expand('<cword>') .. '//g<left><left>' end,
  { desc = 'Replace word under cursor', expr = true }
)

-- stylua: ignore start
-- diagnostics
local enable_diagnostics_keymaps = false

if enable_diagnostics_keymaps then
  local diagnostic_goto = function(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function()
      go({ severity = severity })
    end
  end

  map("n", ">d", diagnostic_goto(true), { desc = "Next Diagnostic" })
  map("n", "<d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
  map("n", ">e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
  map("n", "<e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
  map("n", ">w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
  map("n", "<w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

  map("n", ">D", diagnostic_goto(true), { desc = "Next Diagnostic" })
  map("n", "<D", diagnostic_goto(false), { desc = "Prev Diagnostic" })
  map("n", ">E", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
  map("n", "<E", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
  map("n", ">W", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
  map("n", "<W", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
end

map({ 'n', 'v' }, 'c', '<cmd>lua vim.g.change = true<cr>c', { desc = 'Change' })

-- toggle options
map("n", "<leader>ua", function() vim.g.minianimate_disable = not vim.g.minianimate_disable end, { desc = "Toggle Mini Animate" })
map('n', '<leader>uS', '<cmd>ToggleAutoSave<cr>', { desc = 'Toggle Autosave' })

if wk_ok then
wk.register({ ['<leader>uz'] = { '<cmd>TransparencyToggle<cr>', 'Transparency Toggle' } })
wk.register({
  ['<leader>ud'] = {
    name = 'Toggle Diagnostics',
    t = { Util.toggle.diagnostics, 'Toggle Diagnostics' },
    d = { '<cmd>ToggleDiagnosticVirtualText<cr>', 'Toggle Virtual Text' },
    l = { '<cmd>ToggleDiagnosticVirtualLines<cr>', 'Toggle Virtual Lines' },
  }
})
end

-- Toggle completion
map('n', '<leader>ue', function()
  local cmp = require('cmp')
  local current_setting = cmp.get_config().completion.autocomplete
  if current_setting and #current_setting > 0 then
    cmp.setup({ completion = { autocomplete = false } })
    vim.notify('Disabled auto completion', vim.log.levels.WARN, { title = 'Options' })
  else
    cmp.setup({ completion = { autocomplete = { cmp.TriggerEvent.TextChanged } } })
    vim.notify('Enabled auto completion', vim.log.levels.INFO, { title = 'Options' })
  end
end, { desc = 'Toggle Auto Completion' })

-- Toggle auto width
map('n', '<leader>uW', function()
  require('windows.autowidth').toggle()
  local is_enabled = require('windows.config').autowidth.enable
  local text = is_enabled and 'Enabled' or 'Disabled'
  local level = is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
  vim.notify(text .. ' autowidth', level, { title = 'Options' })
end, { repeatable = true, desc = 'Windows Toggle Autowidth' })

-- quit
map("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Quit all" })
map('n', '<leader>qa', "<cmd>qa!<cr>", { desc = "Quit all" })

-- Terminal Mappings
map("t", "<esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- tabs
map('n', '<S-up>', '<cmd>tabnext<cr>', { desc = 'Tab Next' })
map('n', '<S-down>', '<cmd>tabprev<cr>', { desc = 'Tab Prev' })
map('n', '<C-t>', '<cmd>tabnew<cr>', { desc = 'Tab New' })
map('n', 'gn', '<cmd>tabnew<cr>', { desc = 'Tab New' })
map('n', 'gq', '<cmd>tabclose<cr>', { desc = 'Tab Close' })

local tabpages = require('util.tabpages')
map('n', '<A-j>', function() tabpages.move_buffer_to_tab('prev', true) end)
map('n', '<A-k>', function() tabpages.move_buffer_to_tab('next', true) end)


-- NOTE: Set <c-f> keymap once again due to configuration issue
vim.keymap.set({ 'n' }, '<C-f>',
  function() require('telescope').extensions.live_grep_args.live_grep_args() end,
  { remap = true, desc = 'Search Workspace' }
)

-- Inlay hints
local function toggle_inlay_hints()
  local is_enabled = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(0, not is_enabled)
  local text = (not is_enabled and 'Enabled' or 'Disabled') .. ' inlay hints'
  local level = not is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
  vim.notify(text, level, { title = 'Options' })
end
map('n', '<leader>uh', toggle_inlay_hints, { repeatable = true, desc = 'Toggle Inlay Hints' })

-- Remap smart-splits to use range
map('n', '<C-left>', function() require('smart-splits').resize_left() end, { repeatable = true, desc = 'Resize left' })
map('n', '<C-down>', function() require('smart-splits').resize_down() end, { repeatable = true, desc = 'Resize down' })
map('n', '<C-up>', function() require('smart-splits').resize_up() end, { repeatable = true, desc = 'Resize up' })
map('n', '<C-right>', function() require('smart-splits').resize_right() end, { repeatable = true, desc = 'Resize right' })

map('n', '<leader>A', '<cmd>silent %y+<cr>', { desc = 'Copy all' })

-- Spelling
map('n', '>S', ']s', { repeatable = true, desc = 'Next Spelling' })
map('n', '>s', ']s', { repeatable = true, desc = 'Next Spelling' })
map('n', '<S', '[s', { repeatable = true, desc = 'Prev Spelling' })
map('n', '<s', '[s', { repeatable = true, desc = 'Prev Spelling' })

-- Copilot
if wk_ok then
  wk.register({ ['<leader>cp'] = { '<cmd>Copilot panel<cr>', 'Copilot Panel' } })
end
map('i', '<C-l>', '') -- Remove ^L insertion with ctrl-l in insert mode

-- jupytext
local jupytext = require('util.jupytext')
map('n', '<leader>ns', function() jupytext:sync() end, { desc = 'Jupytext Sync' })
map('n', '<leader>np', function() jupytext:pair() end, { desc = 'Jupytext Pair' })

-- Create command from keymaps
require('util.commands').create_command_from_keymaps()

-- Folds
