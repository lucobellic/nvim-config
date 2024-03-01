local function split_terminal_right()
  local Terminal = require('toggleterm.terminal').Terminal
  Terminal:new({ direction = 'horizontal' }):open()
end
vim.api.nvim_create_user_command('ToggleTermSplit', split_terminal_right, {})

-- Focus the closest terminal before the current one or next one otherwise
---@param term_id number id of the terminal to focus
local function focus_closest_prev_term(term_id)
  local terminal = require('toggleterm.terminal')
  local open_terms = vim.tbl_filter(function(term) return term:is_open() end, terminal.get_all(false))
  table.sort(open_terms, function(a, b) return a.id < b.id end)

  -- Find the current terminal by id in the sorted list
  local id = 0
  for i, term in ipairs(open_terms) do
    if term.id == term_id then
      id = i
      break
    end
  end

  -- Focus to the closest terminal previous first or next one
  local closest_term = open_terms[id - 1] or open_terms[id + 1]
  if closest_term then
    closest_term:focus()
  end
end

-- Close the current terminal and focus to the closest previous terminal if available
local function shutdown_current_term()
  local terminal = require('toggleterm.terminal')
  local term = terminal.get(terminal.get_focused_id())
  if term then
    focus_closest_prev_term(term.id)
    term:shutdown()
  end
end

vim.api.nvim_create_user_command('ToggleTermShutdown', shutdown_current_term, {})

return {
  'akinsho/toggleterm.nvim',
  cmd = { 'ToggleTerm', 'ToggleTermToggleAll' },
  keys = {
    { '<leader>uP', '<cmd>ToggleTermToggleAll<cr>', desc = 'Toggle All Toggleterm' },
    { '<leader>up', '<cmd>ToggleTerm<cr>', desc = 'Toggle Toggleterm' },
  },
  opts = {
    start_in_insert = false,
    close_on_exit = true,
    shade_terminals = false,
    winbar = {
      enabled = false,
      name_formatter = function(term) --  term: Terminal
        return term.id
      end,
    },
  },
}
