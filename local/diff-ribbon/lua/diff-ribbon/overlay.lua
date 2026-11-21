---@class DiffRibbon.Overlay
---@field buffer? integer
---@field window? integer
---@field placement? DiffRibbon.Placement

---@alias DiffRibbon.Side 'left'|'center'|'right'

--- Overlay rows where blanks are opaque, per overlay side, as `masks[side][row] = true`.
---@alias DiffRibbon.Masks table<DiffRibbon.Side, table<integer, true>>

local kitty = require('diff-ribbon.kitty')

local M = {}

M.highlight = 'DiffRibbonImage'
M.mask_highlight = 'DiffRibbonMask'
M.zindex = 45

local namespace = vim.api.nvim_create_namespace('diff-ribbon')

---@type DiffRibbon.Overlay
local overlay = {}

---@param placement DiffRibbon.Placement
---@return vim.api.keyset.win_config
local function window_config(placement)
  return {
    relative = 'editor',
    row = placement.row,
    col = placement.col,
    width = placement.width,
    height = placement.height,
  }
end

---@param placement DiffRibbon.Placement
local function open(placement)
  if not (overlay.buffer and vim.api.nvim_buf_is_valid(overlay.buffer)) then
    overlay.buffer = vim.api.nvim_create_buf(false, true)
  end
  local config = vim.tbl_extend('force', window_config(placement), {
    style = 'minimal',
    border = 'none',
    focusable = false,
    mouse = false,
    zindex = M.zindex,
    noautocmd = true,
  })
  overlay.window = vim.api.nvim_open_win(overlay.buffer, false, config)
  -- Full blending lets blank cells show the buffers below, so only the ribbon covers them.
  vim.wo[overlay.window].winblend = 100
  vim.wo[overlay.window].wrap = false
end

--- Side of the overlay a column sits on: over the left window, the separator, or the right window.
---@param column integer
---@param width integer
---@return DiffRibbon.Side
local function side(column, width)
  local center = math.floor(width / 2)
  if column < center then
    return 'left'
  elseif column == center then
    return 'center'
  end
  return 'right'
end

---@param id integer
---@return string
local function image_highlight(id) return M.highlight .. id end

--- Build one row with placeholders on ribbon cells and blanks elsewhere.
--- Masked blanks are opaque, so diff colors and underlines below stay hidden behind the ribbon.
---@param row integer
---@param width integer
---@param columns table<integer, true>
---@param masks DiffRibbon.Masks
---@param id integer Image shown by the placeholders
---@return string line
---@return { [1]: integer, [2]: integer, [3]: string }[] ranges Byte ranges and their highlight
local function build_row(row, width, columns, masks, id)
  local line, ranges = '', {}
  for column = 0, width - 1 do
    local cell, group = ' ', nil
    if columns[column] then
      cell, group = kitty.placeholder(row, column), image_highlight(id)
    elseif masks[side(column, width)][row] then
      group = M.mask_highlight
    end
    if group then
      table.insert(ranges, { #line, #line + #cell, group })
    end
    line = line .. cell
  end
  return line, ranges
end

---@param placement DiffRibbon.Placement
---@param cells DiffRibbon.Cells
---@param masks DiffRibbon.Masks
---@param id integer
local function fill(placement, cells, masks, id)
  local lines, row_ranges = {}, {}
  for row = 0, placement.height - 1 do
    lines[row + 1], row_ranges[row + 1] = build_row(row, placement.width, cells[row] or {}, masks, id)
  end
  vim.api.nvim_buf_clear_namespace(overlay.buffer, namespace, 0, -1)
  vim.api.nvim_buf_set_lines(overlay.buffer, 0, -1, false, lines)
  for row, ranges in ipairs(row_ranges) do
    for _, range in ipairs(ranges) do
      vim.api.nvim_buf_set_extmark(
        overlay.buffer,
        namespace,
        row - 1,
        range[1],
        { end_col = range[2], hl_group = range[3] }
      )
    end
  end
end

---@type string?
local highlights_key = nil

--- Colors the terminal reads as image ids, with no blending or the ids would change. The mask uses
--- the editor background, like the clear pixels of ribbon cells. Highlights are only set when they
--- change, since setting one makes Neovim redraw every window.
---@param ids integer[]
function M.set_images(ids)
  local background = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg
  local key = tostring(background) .. ':' .. table.concat(ids, ',')
  if key == highlights_key then
    return
  end
  highlights_key = key
  for _, id in ipairs(ids) do
    vim.api.nvim_set_hl(0, image_highlight(id), { fg = id, bg = background, blend = 0 })
  end
  vim.api.nvim_set_hl(0, M.mask_highlight, { bg = background, blend = 0 })
end

--- Highlights are lost when the color scheme changes, so set them again next time.
function M.reset_highlights() highlights_key = nil end

--- Show placeholders for image `id` on the ribbon `cells` at `placement`, with opaque blanks where `masks` asks.
---@param placement DiffRibbon.Placement
---@param cells DiffRibbon.Cells
---@param masks DiffRibbon.Masks
---@param id integer
function M.show(placement, cells, masks, id)
  if not (overlay.window and vim.api.nvim_win_is_valid(overlay.window)) then
    open(placement)
  elseif not vim.deep_equal(overlay.placement, placement) then
    vim.api.nvim_win_set_config(overlay.window, window_config(placement))
  end
  overlay.placement = placement
  fill(placement, cells, masks, id)
end

function M.hide()
  if overlay.window and vim.api.nvim_win_is_valid(overlay.window) then
    vim.api.nvim_win_close(overlay.window, true)
  end
  overlay.window = nil
  overlay.placement = nil
end

return M
