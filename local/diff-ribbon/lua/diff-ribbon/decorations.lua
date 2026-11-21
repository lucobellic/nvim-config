local M = {}

-- Other plugins, such as a custom statuscolumn, read the gutter colors from this namespace.
M.namespace = vim.api.nvim_create_namespace('diff-ribbon.decorations')

-- Buffers holding marks, so clearing does not visit every buffer.
---@type table<integer, true>
local marked = {}

--- Highlight name for a kind, such as `DiffRibbonGutterAdd`.
---@param prefix string
---@param kind DiffRibbon.Kind
---@return string
local function highlight(prefix, kind) return prefix .. kind:sub(1, 1):upper() .. kind:sub(2) end

--- Color as one number, the form highlights expect.
---@param rgb integer[]
---@return integer
local function to_integer(rgb) return rgb[1] * 0x10000 + rgb[2] * 0x100 + rgb[3] end

--- Groups colored like the ribbons: row backgrounds in the gutter, and underlines at gaps.
---@param palette table<DiffRibbon.Kind, integer[]?>
function M.set_colors(palette)
  -- Line numbers keep their usual color on top of the band.
  local number = vim.api.nvim_get_hl(0, { name = 'LineNr', link = false }).fg

  vim.iter(palette):each(
    ---@param kind DiffRibbon.Kind
    ---@param rgb integer[]
    function(kind, rgb)
      local color = to_integer(rgb)
      vim.api.nvim_set_hl(0, highlight('DiffRibbonGutter', kind), { fg = number, bg = color })
      vim.api.nvim_set_hl(0, highlight('DiffRibbonInsertion', kind), { underline = true, sp = color })
      vim.api.nvim_set_hl(
        0,
        highlight('DiffRibbonGutterInsertion', kind),
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
local function color_rows(buffer, start, count, kind)
  for line = start, start + count - 1 do
    mark(buffer, line, { number_hl_group = highlight('DiffRibbonGutter', kind) })
  end
end

--- Underline the line above a gap, where the ribbon narrows to a line.
---@param buffer integer
---@param line integer Line just above the gap, 1 based
---@param kind DiffRibbon.Kind
local function underline(buffer, line, kind)
  -- Nothing sits above a gap at the very top, so there is no line to underline.
  if line < 1 then
    return
  end

  mark(buffer, line, {
    line_hl_group = highlight('DiffRibbonInsertion', kind),
    number_hl_group = highlight('DiffRibbonGutterInsertion', kind),
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
local function decorate_side(buffer, start, count, kind)
  if count == 0 then
    underline(buffer, start, kind)
  else
    color_rows(buffer, start, count, kind)
  end
end

--- Replace the gutter colors and underlines of both windows with those of `hunks`.
---@param pair DiffRibbon.Pair
---@param hunks DiffRibbon.Hunk[]
function M.show(pair, hunks)
  M.clear()

  -- Only the diff windows show them, even when the same buffer is open elsewhere.
  vim.api.nvim__ns_set(M.namespace, { wins = { pair.left, pair.right } })

  local left, right = vim.api.nvim_win_get_buf(pair.left), vim.api.nvim_win_get_buf(pair.right)
  vim.iter(hunks):each(
    ---@param hunk DiffRibbon.Hunk
    function(hunk)
      decorate_side(left, hunk.left_start, hunk.left_count, hunk.kind)
      decorate_side(right, hunk.right_start, hunk.right_count, hunk.kind)
    end
  )
end

return M
