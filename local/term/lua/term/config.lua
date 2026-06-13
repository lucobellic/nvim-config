---@class TermManagerConfig
---@field defaults TermOpts Default terminal options
---@field terminals table<string, {cmd: string|string[], opts?: TermOpts}> Named terminal definitions

---@class TermManagerConfigModule
---@field config TermManagerConfig Current configuration
local M = {
  config = {},
}

--- Constants for terminal management
M.CONSTANTS = {
  MIN_SIZE = 0.3, -- Minimum terminal size (30%)
  MAX_SIZE = 0.999, -- Maximum terminal size (100%)
  DEFAULT_RESIZE_STEP = 0.1, -- Default resize increment (10%)
  BORDER_UPDATE_DELAY = 200, -- Delay for border update in ms
  AUTOHIDE_DELAY = 100, -- Delay before re-enabling autohide
}

--- Default configuration
---@type TermManagerConfig
M.defaults = {
  defaults = {
    width = 0.6,
    height = 0.6,
    border = 'auto',
    zindex = 50,
    start_insert = false, -- Don't auto-start insert mode to preserve cursor position
  },
  terminals = {},
}

function M.get() return vim.tbl_deep_extend('force', M.defaults, M.config or {}) end

--- Get default width from config
---@return number
function M.get_default_width()
  local cfg = M.get()
  local width = cfg.defaults and cfg.defaults.width
  return type(width) == 'number' and width or M.defaults.defaults.width
end

--- Get default height from config
---@return number
function M.get_default_height()
  local cfg = M.get()
  local height = cfg.defaults and cfg.defaults.height
  return type(height) == 'number' and height or M.defaults.defaults.height
end

--- Get border style respecting vim.g.winborder
---@return string
function M.get_border_style()
  local cfg = M.get()
  local border = cfg.defaults and cfg.defaults.border or 'auto'
  if border == 'auto' then
    local winborder = vim.g.winborder or 'single'
    return winborder == 'none' and 'single' or winborder
  end
  return border
end

--- Validate and normalize size values
---@param value any
---@param fallback number
---@return number
function M.validate_size(value, fallback)
  if type(value) ~= 'number' or value ~= value then
    return fallback
  end
  return math.max(M.CONSTANTS.MIN_SIZE, math.min(value, M.CONSTANTS.MAX_SIZE))
end

return M
