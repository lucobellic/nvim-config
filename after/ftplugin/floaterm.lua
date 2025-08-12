--- Open file path under cursor in a normal window from floaterm
local function open_in_normal_window()
  local file = vim.fn.findfile(vim.fn.expand('<cfile>'))
  if file ~= '' and vim.fn.has_key(vim.api.nvim_win_get_config(vim.fn.win_getid()), 'anchor') then
    vim.fn.execute('FloatermHide')
    vim.fn.execute('e ' .. file)
  end
end

local function refresh_floaterm()
  local buffer = vim.api.nvim_win_get_buf(0)
  vim.api.nvim_call_function('floaterm#window#hide', { buffer })
  vim.api.nvim_call_function('floaterm#terminal#open_existing', { buffer })
end

local function close_current_floaterm()
  local buffer = vim.api.nvim_call_function('floaterm#buflist#curr', {})
  local nb_buffers = #vim.api.nvim_call_function('floaterm#buflist#gather', {})

  if nb_buffers == 0 or buffer < 0 then
    vim.notify('No floaterm to close', vim.log.levels.WARN)
  elseif nb_buffers == 1 then
    vim.api.nvim_call_function('floaterm#terminal#kill', { buffer })
  else
    vim.api.nvim_call_function('floaterm#prev', {})
    vim.api.nvim_call_function('floaterm#terminal#kill', { buffer })
    refresh_floaterm()
  end
end

--- Update current floaterm dimension
--- @param key string 'height' or 'width'
--- @param offset number offset to apply to the dimension in range [0, 1]
local function add_dimension_offset(key, offset)
  local buffer = vim.api.nvim_win_get_buf(0)
  local dim_var = vim.api.nvim_buf_get_var(buffer, 'floaterm_' .. key)
  local dim = dim_var[false] -- I don't get this, but whatever
  local new_dim = math.max(math.min(dim + offset, 0.999), 0.1)
  vim.api.nvim_call_function('floaterm#config#set', { buffer, key, new_dim })
end

-- User commands

vim.api.nvim_create_user_command(
  'OpenInNormalWindow',
  open_in_normal_window,
  { desc = 'Open file in normal window from floating terminal' }
)

vim.api.nvim_create_user_command('FloatermCloseCurrent', close_current_floaterm, { desc = 'Close current floaterm' })

-- Keymaps

local opts = { noremap = true, silent = true, buffer = true }

vim.keymap.set('t', '<c-j>', '<c-j>', { buffer = 0, nowait = true })
vim.keymap.set('t', '<c-k>', '<c-k>', { buffer = 0, nowait = true })

vim.keymap.set({ 'n', 't' }, '<C-down>', function()
  add_dimension_offset('height', -0.1)
  add_dimension_offset('width', -0.1)
  refresh_floaterm()
end, opts)

vim.keymap.set({ 'n', 't' }, '<C-up>', function()
  add_dimension_offset('height', 0.1)
  add_dimension_offset('width', 0.1)
  refresh_floaterm()
end, opts)

vim.keymap.set('n', 'gf', '<cmd>OpenInNormalWindow<cr>', opts)
vim.keymap.set('n', '<C-q>', '<cmd>FloatermCloseCurrent<cr>', opts)
vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:FloatermCloseCurrent<cr>', opts)
vim.keymap.set('t', '<esc>', '<C-\\><C-n>', opts)
vim.keymap.set('t', '<c-esc>', '<esc>', opts)
vim.keymap.set('t', '<c-bs>', '<esc>', opts)

vim.keymap.set('n', 'q', '<cmd>FloatermHide<CR><esc>', opts)
vim.keymap.set('n', '<esc>', '<cmd>FloatermHide<CR><esc>', opts)

vim.keymap.set('n', '<C-l>', '<cmd>FloatermNext<CR>', opts)
vim.keymap.set('n', '<S-right>', '<cmd>FloatermNext<CR>', opts)
vim.keymap.set('t', '<C-l>', '<C-\\><C-n>:FloatermNext<CR>', opts)
vim.keymap.set('t', '<S-right>', '<C-\\><C-n>:FloatermNext<CR>', opts)

vim.keymap.set('n', '<C-h>', '<cmd>FloatermPrev<CR>', opts)
vim.keymap.set('n', '<S-left>', '<cmd>FloatermPrev<CR>', opts)
vim.keymap.set('t', '<C-h>', '<C-\\><C-n>:FloatermPrev<CR>', opts)
vim.keymap.set('t', '<S-left>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

vim.keymap.set('n', '<C-t>', '<cmd>FloatermNew<CR>', opts)
vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:FloatermNew<CR>', opts)

-- Options
vim.opt_local.spell = false
vim.b.miniindentscope_disable = true
vim.b.minianimate_disable = true
