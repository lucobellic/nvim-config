local function split_terminal_right()
  local Terminal = require('toggleterm.terminal').Terminal
  Terminal:new({ direction = 'horizontal' }):open()
end
vim.api.nvim_create_user_command('ToggleTermSplit', split_terminal_right, {})

local function shutdown_currrent_term()
  local terminal = require('toggleterm.terminal')
  local term = terminal.get(terminal.get_focused_id())
  if term then
    term:shutdown()
  end
end
vim.api.nvim_create_user_command('ToggleTermShutdown', shutdown_currrent_term, {})

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

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set({ 't' }, '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set({ 't', 'n' }, '<C-h>', function() term_focus_offset(-1) end, opts)
  vim.keymap.set({ 't', 'n' }, '<C-l>', function() term_focus_offset(1) end, opts)
  vim.keymap.set({ 't', 'n' }, '<C-q>', '<cmd>ToggleTermShutdown<cr>', opts)
  vim.keymap.set({ 't', 'n' }, '<C-t>', '<cmd>ToggleTermSplit<cr>', opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

return {
  'akinsho/toggleterm.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>uP', '<cmd>ToggleTermToggleAll<cr>', desc = 'Toggle All Toggleterm' },
    { '<leader>up', '<cmd>ToggleTerm<cr>', desc = 'Toggle Toggleterm' },
  },
  opts = {
    start_in_insert = false,
    close_on_exit = true,
    shade_terminals = false,
    winbar = {
      enabled = true,
      name_formatter = function(term) --  term: Terminal
        return term.id
      end,
    },
  },
}
