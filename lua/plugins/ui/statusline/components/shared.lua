---@class User.Statusline.Shared
local M = {
  frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  frame = 1,
  requests = 0,
  task_symbols = {
    { 'PENDING', ' ' },
    { 'RUNNING', ' ' },
    { 'SUCCESS', ' ' },
    { 'CANCELED', ' ' },
    { 'FAILURE', ' ' },
  },
}

---@type table<string, string>
local modes = {
  n = 'Normal',
  i = 'Insert',
  v = 'Visual',
  V = 'Visual',
  ['\22'] = 'Visual',
  c = 'Command',
  s = 'Select',
  S = 'Select',
  ['\19'] = 'Select',
  R = 'Replace',
  r = 'Replace',
  ['!'] = 'Command',
  t = 'Terminal',
}

---@public
---@param context User.Statusline.Context
---@return string
function M.primary(context) return 'UserStatuslinePrimary' .. (modes[context.mode:sub(1, 1)] or 'Normal') end

---@public
---@param context User.Statusline.Context
---@return string
function M.secondary(context) return 'UserStatuslineSecondary' .. (modes[context.mode:sub(1, 1)] or 'Normal') end

---@public
---@param context User.Statusline.Context
---@return string
function M.separator(context) return context.mode:sub(1, 1) == 'n' and ' ' or '┃' end

return M
