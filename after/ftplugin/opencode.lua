---@param keys string|string[]
local function send_key(keys)
  local chan = vim.b.terminal_job_id
  if chan then
    vim
      .iter(type(keys) == 'string' and { keys } or keys)
      :map(function(key) return vim.api.nvim_replace_termcodes(key, true, false, true) end)
      :each(function(key) vim.api.nvim_chan_send(chan, key) end)
  end
end

--- Forward mouse clicks (normal mode) to the terminal pty
--- by emitting an xterm SGR mouse sequence to the terminal job.
--- The child process must have enabled mouse reporting (e.g. tmux, nested nvim, etc.).
---@param button integer 0=left,1=middle,2=right
---@param is_release boolean
local function send_mouse_event(button, is_release)
  local chan = vim.b.terminal_job_id
  if not chan then
    return
  end

  local mp = vim.fn.getmousepos()
  -- prefer window-relative positions when available
  local row = mp.winrow or mp.line or 1
  local col = mp.wincol or mp.column or 1

  -- SGR mouse: ESC [ < Cb ; Cx ; Cy (M for press, m for release)
  -- button encoding: 0=left,1=middle,2=right,3=release
  local cb = button or 0
  if is_release then
    cb = 3
  end

  local seq = string.format('\x1b[<%d;%d;%d%s', cb, col, row, is_release and 'm' or 'M')
  vim.api.nvim_chan_send(chan, seq)
end

--- Scroll wheel: SGR encodes wheel as button codes 64 (up) and 65 (down).
---@param up boolean true for scroll up, false for scroll down
local function send_scroll_event(up)
  local chan = vim.b.terminal_job_id
  if not chan then
    return
  end

  local mp = vim.fn.getmousepos()
  local row = mp.winrow or mp.line or 1
  local col = mp.wincol or mp.column or 1

  local cb = up and 64 or 65
  local seq = string.format('\x1b[<%d;%d;%dM', cb, col, row)
  vim.api.nvim_chan_send(chan, seq)
end

vim.keymap.set({ 'n', 't', 'i' }, '<A-l>', '<cmd>OpenCodeNext<cr>', { buffer = true })
vim.keymap.set({ 'n', 't', 'i' }, '<A-h>', '<cmd>OpenCodePrev<cr>', { buffer = true })
vim.keymap.set({ 'n' }, '<S-l>', '<cmd>OpenCodeNext<cr>', { buffer = true })
vim.keymap.set({ 'n' }, '<S-h>', '<cmd>OpenCodePrev<cr>', { buffer = true })
vim.keymap.set({ 'n', 't', 'i' }, '<C-q>', '<cmd>OpenCodeClose<cr>', { buffer = true })
vim.keymap.set({ 'n' }, '<C-t>', '<cmd>OpenCodeNew<cr>', { buffer = true })
require('util.terminal_clipboard').setup()
vim.keymap.set({ 'n' }, '<C-x>', function()
  send_key('<C-x>')
  send_key(vim.fn.getcharstr())
end, { buffer = true })

vim.iter({ '<C-p>', '<tab>', '<cr>' }):each(function(key)
  vim.keymap.set({ 'n' }, key, function() send_key(key) end, { buffer = true })
end)

---@param key string
---@param callback fun()
local function map_mouse(key, callback)
  vim.keymap.set('n', key, function()
    local mouse = vim.fn.getmousepos()
    -- Let Neovim handle other windows, status lines and separators.
    if mouse.winid ~= vim.api.nvim_get_current_win() or mouse.line == 0 then
      return key
    end
    callback()
    return ''
  end, { buffer = true, expr = true })
end

map_mouse('<LeftMouse>', function() send_mouse_event(0, false) end)
map_mouse('<LeftRelease>', function() send_mouse_event(0, true) end)
map_mouse('<RightMouse>', function() send_mouse_event(2, false) end)
map_mouse('<RightRelease>', function() send_mouse_event(2, true) end)
map_mouse('<ScrollWheelUp>', function() send_scroll_event(true) end)
map_mouse('<ScrollWheelDown>', function() send_scroll_event(false) end)
