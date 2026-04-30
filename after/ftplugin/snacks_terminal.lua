vim.wo.spell = false
vim.b.minianimate_disable = true
vim.b.miniindentscope_disable = true
vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.wrap = true

--- Focus the terminal at the given offset (+1 = next, -1 = prev) relative to the current one
local function term_focus_offset(offset)
  local terminals = Snacks.terminal.list()
  if vim.tbl_isempty(terminals) then
    return
  end

  -- Find index of the current buffer in the terminal list
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_idx = nil
  for i, term in ipairs(terminals) do
    if term.buf == current_bufnr then
      current_idx = i
      break
    end
  end

  if not current_idx then
    return
  end

  local target_idx = current_idx + offset
  if target_idx < 1 or target_idx > #terminals then
    return
  end

  local target = terminals[target_idx]
  if target and vim.api.nvim_buf_is_valid(target.buf) then
    local win = vim.fn.bufwinid(target.buf)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
    else
      vim.cmd('sbuffer ' .. target.buf)
    end
  end
end

vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { buffer = true, desc = 'Go to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { buffer = true, desc = 'Go to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { buffer = true, desc = 'Go to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { buffer = true, desc = 'Go to right window' })
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], { buffer = true, desc = 'Go to left window' })
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], { buffer = true, desc = 'Go to lower window' })
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], { buffer = true, desc = 'Go to upper window' })
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], { buffer = true, desc = 'Go to right window' })
vim.keymap.set('n', '<S-h>', function() term_focus_offset(-1) end, { buffer = true, desc = 'Focus previous terminal' })
vim.keymap.set('n', '<S-l>', function() term_focus_offset(1) end, { buffer = true, desc = 'Focus next terminal' })
vim.keymap.set(
  'n',
  '<C-q>',
  function() vim.api.nvim_buf_delete(0, { force = true }) end,
  { buffer = true, desc = 'Close terminal' }
)
vim.keymap.set(
  'n',
  '<C-t>',
  function() Snacks.terminal.toggle(nil, { win = { position = 'bottom' } }) end,
  { buffer = true, desc = 'Open terminal' }
)
vim.keymap.set('n', 'gf', function() require('util.util').open_file() end, { buffer = 0 })
