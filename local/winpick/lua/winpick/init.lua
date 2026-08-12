---@alias Winpick.Border 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|string[]

---@class Winpick.Config
---@field chars? string[] Characters assigned to windows in layout order
---@field border? Winpick.Border Floating hint border
---@field highlight? string Highlight group used for hints
---@field exclude? fun(win: integer, buf: integer): boolean Return true to omit a window

---@class Winpick.Float
---@field win integer
---@field buf integer

---@class Winpick
---@field private config Winpick.Config
local M = {}

---@type Winpick.Config
local defaults = {
  chars = { 'a', 's', 'd', 'f', 'j', 'k', 'l' },
  border = 'single',
  highlight = 'FloatTitle',
  exclude = function(_, buf) return vim.bo[buf].filetype == '' and vim.bo[buf].buftype == 'nofile' end,
}

M.config = defaults

---@param layout table Layout returned by winlayout()
---@param windows integer[]
local function collect_windows(layout, windows)
  if layout[1] == 'leaf' then
    windows[#windows + 1] = layout[2]
    return
  end

  vim.iter(layout[2]):each(function(child) collect_windows(child, windows) end)
end

---@param window integer
---@param char string
---@return Winpick.Float
local function open_hint(window, char)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { char })
  vim.api.nvim_buf_add_highlight(buf, -1, M.config.highlight, 0, 0, -1)

  local width = vim.fn.strdisplaywidth(char)
  local hint = vim.api.nvim_open_win(buf, false, {
    relative = 'win',
    win = window,
    row = math.max(0, math.floor((vim.api.nvim_win_get_height(window) - 1) / 2)),
    col = math.max(0, math.floor((vim.api.nvim_win_get_width(window) - width) / 2)),
    width = width,
    height = 1,
    border = M.config.border,
    focusable = false,
    style = 'minimal',
    noautocmd = true,
  })
  vim.api.nvim_set_option_value('winhl', 'Normal:' .. M.config.highlight .. ',FloatBorder:' .. M.config.highlight, {
    win = hint,
  })

  return { win = hint, buf = buf }
end

---@param hints Winpick.Float[]
local function close_hints(hints)
  vim.iter(hints):each(function(hint)
    if vim.api.nvim_win_is_valid(hint.win) then
      vim.api.nvim_win_close(hint.win, true)
    end
    if vim.api.nvim_buf_is_valid(hint.buf) then
      vim.api.nvim_buf_delete(hint.buf, { force = true })
    end
  end)
end

---@return string?
local function get_char()
  local ok, char = pcall(vim.fn.getchar)
  if not ok then
    return nil
  end
  return type(char) == 'number' and vim.fn.nr2char(char) or char
end

---Configure winpick.
---@public
---@param opts? Winpick.Config
function M.setup(opts) M.config = vim.tbl_deep_extend('force', defaults, opts or {}) end

---Display hints and focus the window selected by one character.
---@public
function M.pick()
  local windows = {}
  collect_windows(vim.fn.winlayout(), windows)
  windows = vim
    .iter(windows)
    :filter(function(window)
      local buf = vim.api.nvim_win_get_buf(window)
      return not M.config.exclude(window, buf)
    end)
    :totable()

  if #windows > #M.config.chars then
    vim.notify('Not enough characters configured for this window layout', vim.log.levels.ERROR, { title = 'winpick' })
    return
  end

  local current = vim.api.nvim_get_current_win()
  local targets = {}
  local hints = {}
  vim.iter(windows):enumerate():each(function(index, window)
    local char = M.config.chars[index]
    if window ~= current then
      targets[char] = window
      hints[#hints + 1] = open_hint(window, char)
    end
  end)

  if vim.tbl_isempty(targets) then
    return
  end

  vim.cmd('redraw')
  local char = get_char()
  close_hints(hints)

  local target = char and targets[char] or nil
  if target and vim.api.nvim_win_is_valid(target) then
    vim.api.nvim_set_current_win(target)
  end
end

return M
