local shared = require('plugins.ui.statusline.components.shared')

---@type User.Statusline.Component
local icon = { provider = '', hl = shared.primary, padding = { left = 1, right = 1 } }

---@type User.Statusline.Component
local git_branch = {
  ---@param context User.Statusline.Context
  ---@return boolean
  condition = function(context) return vim.b[context.bufnr].gitsigns_status_dict ~= nil end,
  ---@param context User.Statusline.Context
  ---@return string
  provider = function(context)
    local text = ' ' .. vim.b[context.bufnr].gitsigns_status_dict.head .. ' '
    return #text > 20 and (text:sub(1, 20) .. '...') or text
  end,
  hl = shared.secondary,
  update = { { event = 'User', pattern = 'GitSignsUpdate' } },
}

---@type User.Statusline.Component
local plugin_updates = {
  ---@param _ User.Statusline.Context
  ---@return boolean
  condition = function(_)
    local lazy = package.loaded['lazy.status']
    return lazy ~= nil and lazy.has_updates()
  end,
  ---@param _ User.Statusline.Context
  ---@return string
  provider = function(_) return package.loaded['lazy.status'].updates() end,
  hl = shared.primary,
  update = { { event = 'User', pattern = { 'LazyCheck', 'LazyUpdate', 'LazyLoad' } } },
}

---@type User.Statusline.Component
local separator = { provider = shared.separator, hl = shared.secondary }

---@type User.Statusline.Component
local debugger = {
  ---@param _ User.Statusline.Context
  ---@return boolean
  condition = function(_)
    local dap = package.loaded.dap
    return dap ~= nil and dap.session() ~= nil
  end,
  ---@param _ User.Statusline.Context
  ---@return string
  provider = function(_) return '  ' .. package.loaded.dap.status() end,
  hl = shared.primary,
}

---@type User.Statusline.Component
local macro = {
  ---@param _ User.Statusline.Context
  ---@return boolean
  condition = function(_) return vim.o.cmdheight == 0 and vim.fn.reg_recording() ~= '' end,
  ---@param _ User.Statusline.Context
  ---@return string
  provider = function(_) return ' ' .. vim.fn.reg_recording() end,
  hl = 'UserStatuslineMacro',
  update = { 'RecordingEnter', 'RecordingLeave' },
}

---@type User.Statusline.Component[]
local left = { icon, separator, git_branch, plugin_updates, debugger, macro }

return left
