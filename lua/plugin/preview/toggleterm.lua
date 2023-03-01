require("toggleterm").setup({
  start_in_insert = false,
  close_on_exit = true
})

local function split_terminal_right()
  local Terminal = require('toggleterm.terminal').Terminal
  Terminal:new({ direction = 'horizontal' }):open()
end
vim.api.nvim_create_user_command('ToggleTermSplit', split_terminal_right, {})

local function shutdown_currrent_term()
  local terminal = require('toggleterm.terminal')
  local term = terminal.get(terminal.get_focused_id())
  if term then term:shutdown() end
end
vim.api.nvim_create_user_command('ToggleTermShutdown', shutdown_currrent_term, {})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  -- TODO: Add shift + arrow mapping to change form terminals in insert mode
  vim.keymap.set({ 't' }, '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set({ 't', 'n' }, '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set({ 't', 'n' }, '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set({ 't', 'n' }, '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set({ 't', 'n' }, '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set({ 't', 'n' }, '<C-q>', "<cmd>ToggleTermShutdown<cr>", opts)
  vim.keymap.set({ 't', 'n' }, "<C-t>", "<cmd>ToggleTermSplit<cr>", opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')
