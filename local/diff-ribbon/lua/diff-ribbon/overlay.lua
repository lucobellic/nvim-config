---@class DiffRibbon.Overlay
---@field buffer? integer
---@field window? integer
---@field placement? DiffRibbon.Placement

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

--- Fill one row with placeholders on ribbon cells and blanks elsewhere.
--- On masked rows, blanks over the right window are opaque, so its colored gutter stays behind the ribbon.
---@param row integer
---@param width integer
---@param columns table<integer, true>
---@param masked boolean
local function fill_row(row, width, columns, masked)
  local first_right_column = math.floor(width / 2) + 1
  local line, ranges = '', {}
  for column = 0, width - 1 do
    local cell, group = ' ', nil
    if columns[column] then
      cell, group = kitty.placeholder(row, column), M.highlight
    elseif masked and column >= first_right_column then
      group = M.mask_highlight
    end
    if group then
      table.insert(ranges, { #line, #line + #cell, group })
    end
    line = line .. cell
  end
  vim.api.nvim_buf_set_lines(overlay.buffer, row, row + 1, false, { line })
  vim.iter(ranges):each(
    function(range)
      vim.api.nvim_buf_set_extmark(
        overlay.buffer,
        namespace,
        row,
        range[1],
        { end_col = range[2], hl_group = range[3] }
      )
    end
  )
end

---@param placement DiffRibbon.Placement
---@param cells DiffRibbon.Cells
---@param masked_rows table<integer, true>
local function fill(placement, cells, masked_rows)
  vim.api.nvim_buf_clear_namespace(overlay.buffer, namespace, 0, -1)
  vim.api.nvim_buf_set_lines(overlay.buffer, 0, -1, false, {})
  for row = 0, placement.height - 1 do
    fill_row(row, placement.width, cells[row] or {}, masked_rows[row] == true)
  end
end

--- Set the color the terminal reads as the image id. No blending, or the id would change.
--- The mask uses the editor background, like the clear pixels of the ribbon cells.
---@param id integer
function M.set_image(id)
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  vim.api.nvim_set_hl(0, M.highlight, { fg = id, bg = normal.bg, blend = 0 })
  vim.api.nvim_set_hl(0, M.mask_highlight, { bg = normal.bg, blend = 0 })
end

--- Show placeholders on the ribbon `cells` at `placement`, masking the right gutter on `masked_rows`.
---@param placement DiffRibbon.Placement
---@param cells DiffRibbon.Cells
---@param masked_rows table<integer, true>
function M.show(placement, cells, masked_rows)
  if not (overlay.window and vim.api.nvim_win_is_valid(overlay.window)) then
    open(placement)
  elseif not vim.deep_equal(overlay.placement, placement) then
    vim.api.nvim_win_set_config(overlay.window, window_config(placement))
  end
  overlay.placement = placement
  fill(placement, cells, masked_rows)
end

function M.hide()
  if overlay.window and vim.api.nvim_win_is_valid(overlay.window) then
    vim.api.nvim_win_close(overlay.window, true)
  end
  overlay.window = nil
  overlay.placement = nil
end

return M
