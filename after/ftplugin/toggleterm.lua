vim.wo.spell = false
vim.b.minianimate_disable = true
vim.b.miniindentscope_disable = true
vim.wo.number = false
vim.wo.relativenumber = false

local function term_focus_offset(offset)
  local terminal = require('toggleterm.terminal')
  local current_id = terminal.get_focused_id()
  if current_id then
    local term = terminal.get(current_id + offset)
    if term then
      if term:is_open() then
        term:focus()
      else
        term:open()
      end
    end
  end
end

local close_term = function()
  local terminal = require('toggleterm.terminal')
  local current_id = terminal.get_focused_id()
  if current_id then
    terminal.get(current_id):shutdown()
  else
    vim.api.nvim_buf_delete(0, { force = true })
  end
end

vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = true })
vim.keymap.set('n', '<S-h>', function() term_focus_offset(-1) end, { buffer = true, desc = 'Focus previous terminal' })
vim.keymap.set('n', '<S-l>', function() term_focus_offset(1) end, { buffer = true, desc = 'Focus next terminal' })
vim.keymap.set('n', '<C-q>', function() close_term() end, { buffer = true, desc = 'Close terminal' })
vim.keymap.set('n', '<C-t>', '<cmd>ToggleTermSplit<cr>', { buffer = true, desc = 'Open terminal' })
vim.keymap.set('n', 'gf', function() require('util.util').open_file() end, { buffer = 0 })
