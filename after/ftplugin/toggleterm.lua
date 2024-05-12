vim.opt_local.spell = false
vim.b.minianimate_disable = true
vim.b.miniindentscope_disable = true
vim.opt_local.number = false
vim.opt_local.relativenumber = false

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

local opts = { buffer = true }
vim.keymap.set({ 't' }, '<esc>', [[<C-\><C-n>]], opts)
vim.keymap.set({ 't', 'n' }, '<S-h>', function() term_focus_offset(-1) end, opts)
vim.keymap.set({ 't', 'n' }, '<S-l>', function() term_focus_offset(1) end, opts)
vim.keymap.set({ 't', 'n' }, '<C-q>', '<cmd>ToggleTermShutdown<cr>', opts)
vim.keymap.set({ 't', 'n' }, '<C-t>', '<cmd>ToggleTermSplit<cr>', opts)
vim.keymap.set({ 'n' }, 'gf', function() open_file() end, { buffer = 0 })
