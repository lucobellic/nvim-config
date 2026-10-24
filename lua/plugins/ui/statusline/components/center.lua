---@type User.Statusline.Component
local layout = {
  ---@param _ User.Statusline.Context
  ---@return boolean
  condition = function(_) return vim.g.layout == 'layout' and package.loaded.layout ~= nil end,
  ---@param _ User.Statusline.Context
  ---@return string
  provider = function(_) return table.concat(package.loaded.layout.get_statusline('bottom')) end,
  format = true,
}

---@type User.Statusline.Component[]
local center = { layout }

return center
