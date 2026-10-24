---@class User.Statusline.Context
---@field winid integer
---@field bufnr integer
---@field width integer Available display cells
---@field active boolean

---@alias User.Statusline.Section string|fun(context: User.Statusline.Context): string

---@class User.Statusline.Options
---@field left? User.Statusline.Section
---@field center? User.Statusline.Section
---@field right? User.Statusline.Section
---@field highlight? string Base highlight for sections and spacing

---@class User.Statusline
local M = {}

---@type User.Statusline.Options
local sections = {}

---@param section? User.Statusline.Section
---@param context User.Statusline.Context
---@return string
local function resolve(section, context)
  if type(section) == 'function' then
    return section(context)
  end
  return section or ''
end

---Escape literal text before including it in a statusline format.
---@public
---@param text string
---@return string
function M.escape(text)
  local escaped = text:gsub('%%', '%%%%')
  return escaped
end

---Wrap a native format in a highlight and restore the surrounding group.
---@public
---@param format string
---@param group string
---@param restore? string
---@return string
function M.highlight(format, group, restore)
  return '%#' .. group .. '#' .. format .. (restore and ('%#' .. restore .. '#') or '%*')
end

---Render native formats with a center fixed to the full statusline width.
---@public
---@return string
function M.render()
  local current = vim.api.nvim_get_current_win()
  local winid = vim.g.statusline_winid or current
  ---@type User.Statusline.Context
  local context = {
    winid = winid,
    bufnr = vim.api.nvim_win_get_buf(winid),
    width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(winid),
    active = winid == current,
  }
  local left = resolve(sections.left, context)
  local center = resolve(sections.center, context)
  local right = resolve(sections.right, context)
  local base = sections.highlight and ('%#' .. sections.highlight .. '#') or ''
  local reset = base ~= '' and base or '%*'
  local sides = base .. '%<' .. left .. reset .. '%=' .. right .. reset
  if center == '' then
    return sides
  end

  -- One extra cell is enough to detect content that cannot fit.
  local options = { winid = winid, maxwidth = context.width + 1 }
  local center_width = vim.api.nvim_eval_statusline(center, options).width
  if center_width == 0 then
    return sides
  end
  local left_width = vim.api.nvim_eval_statusline(left, options).width
  local right_width = vim.api.nvim_eval_statusline(right, options).width
  local center_start = math.floor((context.width - center_width) / 2)
  local left_gap = center_start - left_width
  local right_gap = context.width - right_width - center_start - center_width
  if left_gap < 0 or right_gap < 0 then
    return sides
  end

  return base
    .. left
    .. reset
    .. string.rep(' ', left_gap)
    .. center
    .. reset
    .. string.rep(' ', right_gap)
    .. right
    .. reset
end

---Set sections and install the native statusline expression.
---@public
---@param options User.Statusline.Options
function M.setup(options)
  sections = {
    left = options.left,
    center = options.center,
    right = options.right,
    highlight = options.highlight,
  }
  vim.o.statusline = "%!v:lua.require'statusline'.render()"
end

return M
