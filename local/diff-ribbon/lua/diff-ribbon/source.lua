---@class DiffRibbon.Pair
---@field left integer Window
---@field right integer Window

local M = {}

--- Whether `window` exists and sits in the current tab.
---@param window? integer
---@return boolean
local function visible(window)
  return window ~= nil
    and vim.api.nvim_win_is_valid(window)
    and vim.api.nvim_win_get_tabpage(window) == vim.api.nvim_get_current_tabpage()
end

--- Windows of the current diffview-plus view when its layout is one of `layouts`.
---@param layouts string[]
---@return DiffRibbon.Pair?
function M.pair(layouts)
  -- Only look once diffview-plus is loaded, so scrolling elsewhere never loads it.
  local lib = package.loaded['diffview.lib']
  local view = lib and lib.get_current_view()
  local layout = view and view.cur_layout
  if not (layout and vim.list_contains(layouts, layout.name)) then
    return nil
  end

  local first, second = layout.a and layout.a.id, layout.b and layout.b.id

  if not (visible(first) and visible(second)) then
    return nil
  end

  -- A fully added or deleted file has an empty side, so a single ribbon would only repeat the highlight.
  if layout.a:is_nulled() or layout.b:is_nulled() then
    return nil
  end

  -- Order by column, so `left` is the window on the left of the screen.
  if vim.api.nvim_win_get_position(first)[2] > vim.api.nvim_win_get_position(second)[2] then
    first, second = second, first
  end

  return { left = first, right = second }
end

return M
