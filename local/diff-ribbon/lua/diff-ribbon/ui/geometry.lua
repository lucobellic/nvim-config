---@class DiffRibbon.Viewport
---@field window integer
---@field top_line integer
---@field bottom_line integer
---@field text_row integer Editor row (0 based) of the first text row
---@field height integer

---@class DiffRibbon.Placement
---@field row integer Editor row (0 based)
---@field col integer Editor column (0 based)
---@field width integer
---@field height integer

---@class DiffRibbon.Ribbon
---@field kind DiffRibbon.Kind
---@field left_top number Rows from the top of the overlay
---@field left_bottom number
---@field right_top number
---@field right_bottom number

local M = {}

--- Visible lines of a window and where its text starts on screen.
---@param window integer
---@return DiffRibbon.Viewport
function M.viewport(window)
  local info = vim.fn.getwininfo(window)[1]
  return {
    window = window,
    top_line = info.topline,
    bottom_line = info.botline,
    -- Text starts below the winbar, if the window has one.
    text_row = info.winrow - 1 + info.winbar,
    height = info.height,
  }
end

--- Overlay centered on the separator between the two windows, or nil when they do not touch.
--- It stays within the text rows of both windows, so the tabline, winbars and statuslines stay visible.
---@param left DiffRibbon.Viewport
---@param right DiffRibbon.Viewport
---@param width integer
---@return DiffRibbon.Placement?
function M.placement(left, right, width)
  local separator = vim.api.nvim_win_get_position(left.window)[2] + vim.api.nvim_win_get_width(left.window)
  local row = math.max(left.text_row, right.text_row)
  local height = math.min(left.text_row + left.height, right.text_row + right.height) - row

  -- The right window must start just after the separator, or another window sits between them.
  if vim.api.nvim_win_get_position(right.window)[2] ~= separator + 1 or height < 1 then
    return nil
  end

  return { row = row, col = separator - math.floor(width / 2), width = width, height = height }
end

--- Screen rows used by lines `first` to `last`, counting wrapped lines and virtual lines.
---@param window integer
---@param first integer
---@param last integer
---@return integer
local function text_height(window, first, last)
  if last < first then
    return 0
  end

  return vim.api.nvim_win_text_height(window, { start_row = first - 1, end_row = last - 1 }).all
end

--- Screen rows between the top of the viewport and the boundary just above `line`.
---@param viewport DiffRibbon.Viewport
---@param line integer
---@return integer
local function boundary_row(viewport, line)
  if line >= viewport.top_line then
    return text_height(viewport.window, viewport.top_line, line - 1)
  end

  -- Lines above the viewport give a negative row, so the ribbon can start off screen.
  return -text_height(viewport.window, line, viewport.top_line - 1)
end

--- First and last boundary lines of one side of a hunk. An empty side is an insertion point after `start`.
---@param start integer
---@param count integer
---@return integer, integer
local function side_bounds(start, count)
  if count == 0 then
    return start + 1, start + 1
  end

  return start, start + count
end

--- A hunk is hidden only when both of its sides are out of view on the same end.
---@param left DiffRibbon.Viewport
---@param right DiffRibbon.Viewport
---@param hunk DiffRibbon.Hunk
---@return boolean
local function off_screen(left, right, hunk)
  local left_first, left_last = side_bounds(hunk.left_start, hunk.left_count)
  local right_first, right_last = side_bounds(hunk.right_start, hunk.right_count)

  local above = left_last < left.top_line and right_last < right.top_line
  local below = left_first > left.bottom_line + 1 and right_first > right.bottom_line + 1
  return above or below
end

--- Ribbons of the visible hunks, in overlay rows.
---@param hunks DiffRibbon.Hunk[]
---@param left DiffRibbon.Viewport
---@param right DiffRibbon.Viewport
---@param placement DiffRibbon.Placement
---@return DiffRibbon.Ribbon[]
function M.ribbons(hunks, left, right, placement)
  -- Both windows may start on different rows, for example when only one has a winbar.
  local left_offset = left.text_row - placement.row
  local right_offset = right.text_row - placement.row

  return vim
    .iter(hunks)
    :filter(
      ---@param hunk DiffRibbon.Hunk
      function(hunk) return not off_screen(left, right, hunk) end
    )
    :map(
      ---@param hunk DiffRibbon.Hunk
      ---@return DiffRibbon.Ribbon
      function(hunk)
        local left_first, left_last = side_bounds(hunk.left_start, hunk.left_count)
        local right_first, right_last = side_bounds(hunk.right_start, hunk.right_count)
        ---@diagnostic disable-next-line: missing-return-value
        return {
          kind = hunk.kind,
          left_top = boundary_row(left, left_first) + left_offset,
          left_bottom = boundary_row(left, left_last) + left_offset,
          right_top = boundary_row(right, right_first) + right_offset,
          right_bottom = boundary_row(right, right_last) + right_offset,
        }
      end
    )
    :totable()
end

return M
