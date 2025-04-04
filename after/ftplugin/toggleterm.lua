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

local function open_file()
  -- Find the first open window with a valid buffer
  local buffers = vim.tbl_filter(
    function(buffer) return #buffer.windows >= 1 end,
    vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })
  )
  local first_window = #buffers > 0 and buffers[1].windows[1] or nil

  -- Open file under cursor in first valid window or in new window otherwise
  local filename = vim.fn.findfile(vim.fn.expand('<cfile>'))
  if vim.fn.filereadable(filename) == 1 then
    if first_window then
      vim.api.nvim_set_current_win(first_window)
    end
    vim.cmd('edit ' .. filename)
  else
    vim.notify('File does not exist: ' .. filename)
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
vim.keymap.set('n', 'gf', function() open_file() end, { buffer = 0 })
