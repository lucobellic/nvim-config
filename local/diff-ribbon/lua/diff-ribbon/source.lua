---@class DiffRibbon.Pair
---@field left integer Window
---@field right integer Window

---@class DiffRibbon.View
---@field windows integer[] From left to right
---@field base integer Index in `windows` of the one Neovim compares the others with
---@field pairs DiffRibbon.Pair[] Neighbouring windows, from left to right

local M = {}

-- Layout windows, in the order diffview-plus names them.
local symbols = { 'a', 'b', 'c', 'd' }

--- Whether `window` exists and sits in the current tab.
---@param window? integer
---@return boolean
local function visible(window)
  return window ~= nil
    and vim.api.nvim_win_is_valid(window)
    and vim.api.nvim_win_get_tabpage(window) == vim.api.nvim_get_current_tabpage()
end

--- Diff windows of the current diffview-plus view when its layout is one of `layouts`, with their
--- neighbouring pairs: one pair for two windows, two pairs for three.
---@param layouts string[]
---@return DiffRibbon.View?
function M.view(layouts)
  -- Only look once diffview-plus is loaded, so scrolling elsewhere never loads it.
  local lib = package.loaded['diffview.lib']
  local view = lib and lib.get_current_view()
  local layout = view and view.cur_layout
  if not (layout and vim.list_contains(layouts, layout.name)) then
    return nil
  end

  local windows = vim.iter(symbols):map(function(symbol) return layout[symbol] end):totable()
  if #windows < 2 then
    return nil
  end

  for _, window in ipairs(windows) do
    if not visible(window.id) then
      return nil
    end
    -- A fully added or deleted file has an empty side, so a single ribbon would only repeat the highlight.
    if window:is_nulled() then
      return nil
    end
  end

  -- Order by column, so each pair has its left window on the left of the screen.
  local ids = vim.tbl_map(function(window) return window.id end, windows)
  table.sort(
    ids,
    function(first, second) return vim.api.nvim_win_get_position(first)[2] < vim.api.nvim_win_get_position(second)[2] end
  )

  local window_pairs = {}
  for index = 1, #ids - 1 do
    table.insert(window_pairs, { left = ids[index], right = ids[index + 1] })
  end

  -- diffview-plus turns on diff mode in its window order, so Neovim takes the first one as base.
  local base = vim.fn.index(ids, windows[1].id) + 1
  return { windows = ids, base = base, pairs = window_pairs }
end

return M
