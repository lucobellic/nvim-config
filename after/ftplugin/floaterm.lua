--- Open file path under cursor in a normal window from floaterm
local function open_in_normal_window()
  local file = vim.fn.findfile(vim.fn.expand('<cfile>'))
  if file ~= '' and vim.fn.has_key(vim.api.nvim_win_get_config(vim.fn.win_getid()), 'anchor') then
    vim.fn.execute('FloatermHide')
    vim.fn.execute('e ' .. file)
  end
end

--- HACK: Refresh floaterm to update content visualization
--- @param nb_buffers number|nil number of floaterm buffers
local function refresh_floaterm(nb_buffers)
  local nb_buffers = nb_buffers or #vim.api.nvim_call_function('floaterm#buflist#gather', {})
  if nb_buffers > 2 then
    vim.api.nvim_call_function('floaterm#prev', {})
    vim.api.nvim_call_function('floaterm#next', {})
  else
    local buffer = vim.api.nvim_win_get_buf(0)
    vim.api.nvim_call_function('floaterm#window#hide', { buffer })
    vim.api.nvim_call_function('floaterm#terminal#open_existing', { buffer })
  end
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
    refresh_floaterm(nb_buffers)
  end
  --- HACK: trigger ModeChanged autocommand to fix untriggered mode changed
  vim.cmd('doautocmd ModeChanged t:n')
end

--- Open existing floaterm by index
--- @param index number floaterm index to open (1-based)
local function open_existing_floaterm(index)
  local buffers = vim.api.nvim_call_function('floaterm#buflist#gather', {})
  if index <= #buffers then
    local buffer = buffers[index]
    vim.api.nvim_call_function('floaterm#terminal#open_existing', { buffer })
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

-- Keymaps

local opts = { noremap = true, silent = true, buffer = true }

for i = 1, 9 do
  vim.keymap.set({ 'n', 't' }, '<C-' .. i .. '>', function() open_existing_floaterm(i) end, opts)
end

vim.keymap.set('t', '<c-j>', '<c-j>', { buffer = true, nowait = true })
vim.keymap.set('t', '<c-k>', '<c-k>', { buffer = true, nowait = true })

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
vim.keymap.set('n', '<C-q>', close_current_floaterm, opts)
vim.keymap.set('t', '<C-q>', close_current_floaterm, opts)
vim.keymap.set('t', '<esc>', '<C-\\><C-n>', opts)
vim.keymap.set('t', '<c-esc>', '<esc>', opts)
vim.keymap.set('t', '<c-bs>', '<esc>', opts)

vim.keymap.set('n', 'q', '<cmd>FloatermHide<CR><esc>', opts)
vim.keymap.set('n', '<esc>', '<cmd>FloatermHide<CR><esc>', opts)

local function floaterm_next() vim.api.nvim_call_function('floaterm#next', {}) end
vim.keymap.set('n', '<C-l>', floaterm_next, opts)
vim.keymap.set('n', '<S-right>', floaterm_next, opts)
vim.keymap.set('t', '<C-l>', floaterm_next, opts)
vim.keymap.set('t', '<S-right>', floaterm_next, opts)

local function floaterm_prev() vim.api.nvim_call_function('floaterm#prev', {}) end
vim.keymap.set('n', '<C-h>', floaterm_prev, opts)
vim.keymap.set('n', '<S-left>', floaterm_prev, opts)
vim.keymap.set('t', '<C-h>', floaterm_prev, opts)
vim.keymap.set('t', '<S-left>', floaterm_prev, opts)

-- TODO: figure out how to call foaterm#new with proper arguments
-- local function floaterm_new()
--   vim.api.nvim_call_function('floaterm#new', { false, '', {}, {} })
-- end
-- vim.keymap.set('n', '<C-t>', floaterm_new, opts)
-- vim.keymap.set('t', '<C-t>', floaterm_new, opts)

vim.keymap.set('n', '<C-t>', '<cmd>FloatermNew<CR>', opts)
vim.keymap.set('t', '<C-t>', '<C-\\><C-n>:FloatermNew<CR>', opts)

-- Options
vim.opt_local.spell = false
vim.b.miniindentscope_disable = true
vim.b.minianimate_disable = true
