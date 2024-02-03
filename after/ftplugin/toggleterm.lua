vim.opt_local.spell = false
vim.b.minianimate_disable = true
vim.b.miniindentscope_disable = true
vim.opt_local.number = false
vim.opt_local.relativenumber = false

local function term_focus_offset(offset)
  local terminal = require('toggleterm.terminal')
  local current_id = terminal.get_focused_id()
  local term = terminal.get(current_id + offset)
  if term then
    if term:is_open() then
      term:focus()
    else
      term:open()
    end
  end
end

local opts = { buffer = 0 }
vim.keymap.set({ 't' }, '<esc>', [[<C-\><C-n>]], opts)
vim.keymap.set({ 't', 'n' }, '<C-h>', function() term_focus_offset(-1) end, opts)
vim.keymap.set({ 't', 'n' }, '<C-l>', function() term_focus_offset(1) end, opts)
vim.keymap.set({ 't', 'n' }, '<C-q>', '<cmd>ToggleTermShutdown<cr>', opts)
vim.keymap.set({ 't', 'n' }, '<C-t>', '<cmd>ToggleTermSplit<cr>', opts)
