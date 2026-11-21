---@class DiffRibbon.Pair
---@field left integer Window
---@field right integer Window

---@class DiffRibbon.View
---@field windows integer[] Every diff window, in diffview-plus order. It turns on diff mode in that order, so Neovim compares the others with the first one
---@field pairs DiffRibbon.Pair[] Windows that sit side by side, from left to right

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

--- Whether `right` sits just right of `left`, across one separator, with rows in common.
---@param left integer
---@param right integer
---@return boolean
local function side_by_side(left, right)
  local left_row, left_col = unpack(vim.api.nvim_win_get_position(left))
  local right_row, right_col = unpack(vim.api.nvim_win_get_position(right))
  local touching = right_col == left_col + vim.api.nvim_win_get_width(left) + 1
  local overlapping = left_row < right_row + vim.api.nvim_win_get_height(right)
    and right_row < left_row + vim.api.nvim_win_get_height(left)

  return touching and overlapping
end

--- Windows that sit side by side, each pair from left to right, ordered by position on screen.
--- Windows stacked above one another get no ribbon.
---@param ids integer[]
---@return DiffRibbon.Pair[]
local function neighbours(ids)
  local result = {}
  for _, left in ipairs(ids) do
    for _, right in ipairs(ids) do
      if left ~= right and side_by_side(left, right) then
        table.insert(result, { left = left, right = right })
      end
    end
  end

  local function position(pair) return vim.api.nvim_win_get_position(pair.left) end
  table.sort(result, function(first, second)
    local first_position, second_position = position(first), position(second)
    if first_position[1] ~= second_position[1] then
      return first_position[1] < second_position[1]
    end
    return first_position[2] < second_position[2]
  end)

  return result
end

--- Diff windows of the current diffview-plus view when its layout is one of `layouts`, with the
--- pairs that sit side by side: one pair for two windows, two for three in a row.
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

  local ids = vim.tbl_map(function(window) return window.id end, windows)
  local window_pairs = neighbours(ids)
  if #window_pairs == 0 then
    return nil
  end

  return { windows = ids, pairs = window_pairs }
end

return M
