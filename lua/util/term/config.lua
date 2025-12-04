---@class TermManagerConfig
---@field defaults TermOpts Default terminal options
---@field terminals table<string, {cmd: string|string[], opts?: TermOpts}> Named terminal definitions

---@class TermManagerConfigModule
local M = {}

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

--- Current configuration
---@type TermManagerConfig
M.config = vim.tbl_deep_extend('force', {}, M.defaults)

--- Setup configuration
---@param user_config? TermManagerConfig
function M.setup(user_config) M.config = vim.tbl_deep_extend('force', M.config, user_config or {}) end

--- Get current configuration
---@return TermManagerConfig
function M.get() return M.config end

--- Get border style respecting vim.g.winborder
---@return string
function M.get_border_style()
  local border = M.config.defaults.border or 'auto'
  if border == 'auto' then
    local winborder = vim.g.winborder or 'single'
    return winborder == 'none' and 'single' or winborder
  end
  return border
end

return M
