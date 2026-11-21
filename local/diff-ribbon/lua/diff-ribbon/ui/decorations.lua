--- Hunks of one pair of windows, with the colors of its ribbon.
---@class DiffRibbon.Decoration
---@field pair DiffRibbon.Pair
---@field hunks DiffRibbon.Hunk[]
---@field palette DiffRibbon.Palette

local M = {}

-- Other plugins, such as a custom statuscolumn, read the gutter colors from this namespace.
M.namespace = vim.api.nvim_create_namespace('diff-ribbon.decorations')

-- Buffers holding marks, so clearing does not visit every buffer.
---@type table<integer, true>
local marked = {}

--- Highlight name for a kind of the ribbon at `index`, such as `DiffRibbonGutterAdd1`. Each ribbon
--- has its own, since its colors come from its own windows.
---@param prefix string
---@param kind DiffRibbon.Kind
---@param index integer
---@return string
local function highlight(prefix, kind, index) return prefix .. kind:sub(1, 1):upper() .. kind:sub(2) .. index end

--- Color as one number, the form highlights expect.
---@param rgb integer[]
---@return integer
local function to_integer(rgb) return rgb[1] * 0x10000 + rgb[2] * 0x100 + rgb[3] end

--- Groups colored like the ribbon at `index`: row backgrounds in the gutter, and underlines at gaps.
---@param index integer
---@param palette DiffRibbon.Palette
local function set_colors(index, palette)
  -- Line numbers keep their usual color on top of the band.
  local number = vim.api.nvim_get_hl(0, { name = 'LineNr', link = false }).fg

  vim.iter(palette):each(
    ---@param kind DiffRibbon.Kind
    ---@param rgb integer[]
    function(kind, rgb)
      local color = to_integer(rgb)
      vim.api.nvim_set_hl(0, highlight('DiffRibbonGutter', kind, index), { fg = number, bg = color })
      vim.api.nvim_set_hl(0, highlight('DiffRibbonInsertion', kind, index), { underline = true, sp = color })
      vim.api.nvim_set_hl(
        0,
        highlight('DiffRibbonGutterInsertion', kind, index),
        { fg = number, underline = true, sp = color }
      )
    end
  )
end

--- Decorate one line and remember the buffer for clearing.
---@param buffer integer
---@param line integer 1 based
---@param options vim.api.keyset.set_extmark
local function mark(buffer, line, options)
  vim.api.nvim_buf_set_extmark(buffer, M.namespace, line - 1, 0, options)
  marked[buffer] = true
end

--- Color the gutter of every changed line, so the band runs from the ribbon to the text.
---@param buffer integer
---@param start integer
---@param count integer
---@param kind DiffRibbon.Kind
---@param index integer
local function color_rows(buffer, start, count, kind, index)
  for line = start, start + count - 1 do
    mark(buffer, line, { number_hl_group = highlight('DiffRibbonGutter', kind, index) })
  end
end

--- Underline the line above a gap, where the ribbon narrows to a line.
---@param buffer integer
---@param line integer Line just above the gap, 1 based
---@param kind DiffRibbon.Kind
---@param index integer
---@param gutter boolean Whether the underline also crosses the gutter
local function underline(buffer, line, kind, index, gutter)
  -- Nothing sits above a gap at the very top, so there is no line to underline.
  if line < 1 then
    return
  end

  mark(buffer, line, {
    line_hl_group = highlight('DiffRibbonInsertion', kind, index),
    number_hl_group = gutter and highlight('DiffRibbonGutterInsertion', kind, index) or nil,
  })
end

--- Remove every gutter color and underline this plugin added.
function M.clear()
  vim.iter(vim.tbl_keys(marked)):each(
    ---@param buffer integer
    function(buffer)
      if vim.api.nvim_buf_is_valid(buffer) then
        vim.api.nvim_buf_clear_namespace(buffer, M.namespace, 0, -1)
      end
    end
  )

  marked = {}
end

--- An empty side is a gap, so it gets an underline instead of colored rows.
---@param buffer integer
---@param start integer
---@param count integer
---@param kind DiffRibbon.Kind
---@param index integer
---@param gutter boolean Whether this ribbon colors the window's gutter
local function decorate_side(buffer, start, count, kind, index, gutter)
  if count == 0 then
    underline(buffer, start, kind, index, gutter)
  elseif gutter then
    color_rows(buffer, start, count, kind, index)
  end
end

--- Replace the gutter colors and underlines of every window with those of `decorations`. A window
--- between two others belongs to two ribbons. The gutter sits on the left of a window, so it takes
--- the colors of the ribbon touching it, the one on its left. A window with no ribbon on its left
--- takes the colors of the one on its right. Underlines run through the text up to both ribbons,
--- so every ribbon draws them. Windows without a ribbon, such as one stacked below, stay plain.
---@param decorations DiffRibbon.Decoration[]
function M.show(decorations)
  M.clear()

  -- Only the windows next to a ribbon show them, even when the same buffer is open elsewhere.
  ---@type table<integer, true>
  local windows = {}
  for _, decoration in ipairs(decorations) do
    windows[decoration.pair.left] = true
    windows[decoration.pair.right] = true
  end
  vim.api.nvim__ns_set(M.namespace, { wins = vim.tbl_keys(windows) })

  ---@type table<integer, true>
  local has_left_ribbon = {}
  for _, decoration in ipairs(decorations) do
    has_left_ribbon[decoration.pair.right] = true
  end

  for index, decoration in ipairs(decorations) do
    set_colors(index, decoration.palette)

    local left = vim.api.nvim_win_get_buf(decoration.pair.left)
    local right = vim.api.nvim_win_get_buf(decoration.pair.right)
    local left_gutter = not has_left_ribbon[decoration.pair.left]
    vim.iter(decoration.hunks):each(
      ---@param hunk DiffRibbon.Hunk
      function(hunk)
        decorate_side(left, hunk.left_start, hunk.left_count, hunk.kind, index, left_gutter)
        decorate_side(right, hunk.right_start, hunk.right_count, hunk.kind, index, true)
      end
    )
  end
end

return M
