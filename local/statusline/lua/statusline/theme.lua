---@class User.Statusline.Theme
local M = {}

local colors = {
  gray = '#70809b',
  black = '#0F131A',
  red = '#F07178',
  purple = '#D2A6FF',
  green = '#AAD94C',
  blue = '#59C2FF',
  orange = '#FFB454',
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

---Copy task foregrounds without inheriting plugin backgrounds.
---@public
function M.refresh_tasks()
  vim.iter({ 'FAILURE', 'CANCELED', 'SUCCESS', 'RUNNING', 'PENDING' }):each(
    ---@param status string
    function(status)
      local highlight = vim.api.nvim_get_hl(0, { name = 'Overseer' .. status, link = false, create = false })
      vim.api.nvim_set_hl(0, 'UserStatuslineTask' .. status, { fg = highlight.fg })
    end
  )
end

---@public
function M.refresh()
  vim.api.nvim_set_hl(0, 'UserStatuslineBase', { fg = colors.gray })
  vim.api.nvim_set_hl(0, 'UserStatuslineMacro', { fg = colors.orange, italic = true })
  local mode_colors = {
    Normal = colors.gray,
    Insert = colors.green,
    Visual = colors.orange,
    Command = colors.blue,
    Select = colors.purple,
    Replace = colors.red,
    Terminal = colors.purple,
  }
  vim.iter(mode_colors):each(
    ---@param mode string
    ---@param color string
    function(mode, color)
      vim.api.nvim_set_hl(0, 'UserStatuslinePrimary' .. mode, {
        fg = mode == 'Normal' and color or colors.black,
        bg = mode ~= 'Normal' and color or nil,
      })
      vim.api.nvim_set_hl(0, 'UserStatuslineSecondary' .. mode, { fg = color })
    end
  )
  M.refresh_tasks()
end

---@public
---@return string primary
---@return string secondary
---@return string mode
function M.groups()
  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  local name = modes[mode] or 'Normal'
  return 'UserStatuslinePrimary' .. name, 'UserStatuslineSecondary' .. name, mode
end

return M
