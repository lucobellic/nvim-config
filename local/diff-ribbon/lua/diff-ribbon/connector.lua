local config = require('diff-ribbon.config')
local kitty = require('diff-ribbon.kitty')
local overlay = require('diff-ribbon.overlay')
local raster = require('diff-ribbon.raster')

-- The ribbon between two neighbouring windows: its images and its overlay.
---@class DiffRibbon.Connector
---@field image_ids integer[] Two images take turns, see `draw`
---@field image_slot integer Index in `image_ids` of the image the overlay shows
---@field image_key? string Remembers the last inputs, so an unchanged image is not drawn again
---@field overlay DiffRibbon.Overlay
local Connector = {}
Connector.__index = Connector

local M = {}

---@param image_ids integer[]
---@return DiffRibbon.Connector
function M.new(image_ids)
  return setmetatable({ image_ids = image_ids, image_slot = 1, overlay = overlay.new() }, Connector)
end

--- Text that changes whenever the image would look different.
---@param ribbons DiffRibbon.Ribbon[]
---@param placement DiffRibbon.Placement
---@param palette DiffRibbon.Palette
---@return string
local function image_key(ribbons, placement, palette)
  local parts = vim
    .iter(ribbons)
    :map(
      ---@param ribbon DiffRibbon.Ribbon
      ---@return string
      function(ribbon)
        ---@diagnostic disable-next-line: missing-return-value
        return table.concat(
          { ribbon.kind, ribbon.left_top, ribbon.left_bottom, ribbon.right_top, ribbon.right_bottom },
          ','
        )
      end
    )
    :totable()

  local area = table.concat({ placement.row, placement.col, placement.width, placement.height }, ',')
  return table.concat({ area, vim.inspect(palette), table.concat(parts, ';') }, '|')
end

--- Mark the overlay rows where one side of a hunk shows diff colors: its changed lines,
--- or for a gap, the underlined line just above it.
---@param rows table<integer, true>
---@param top number
---@param bottom number
---@param height integer
local function mark_side(rows, top, bottom, height)
  local first, last = math.floor(top), math.ceil(bottom) - 1
  -- A gap has no rows of its own, so mark the underlined row above it.
  if bottom <= top then
    first, last = top - 1, top - 1
  end

  -- Keep only the rows inside the overlay.
  for row = math.max(0, first), math.min(height - 1, last) do
    rows[row] = true
  end
end

--- Rows where overlay blanks must hide the diff colors below: line highlights and underlines on
--- each side, and the separator wherever either side has them.
---@param ribbons DiffRibbon.Ribbon[]
---@param placement DiffRibbon.Placement
---@return DiffRibbon.Masks
local function masks(ribbons, placement)
  local result = { left = {}, center = {}, right = {} }

  vim.iter(ribbons):each(
    ---@param ribbon DiffRibbon.Ribbon
    function(ribbon)
      mark_side(result.left, ribbon.left_top, ribbon.left_bottom, placement.height)
      mark_side(result.right, ribbon.right_top, ribbon.right_bottom, placement.height)
    end
  )

  result.center = vim.tbl_extend('force', result.left, result.right)
  return result
end

--- Draw the ribbon image and show it in the overlay, unless it would look the same as now.
---@param ribbons DiffRibbon.Ribbon[]
---@param placement DiffRibbon.Placement
---@param palette DiffRibbon.Palette
function Connector:draw(ribbons, placement, palette)
  local key = image_key(ribbons, placement, palette)
  if key == self.image_key then
    return
  end
  self.image_key = key

  -- Draw at the real pixel size of the cells, so the ribbon stays sharp.
  local cell = kitty.cell_size() or config.options.cell_size or { width = 10, height = 20 }
  local width, height = math.floor(placement.width * cell.width), math.floor(placement.height * cell.height)
  local bytes, cells = raster.render(ribbons, {
    width = width,
    height = height,
    cell_width = width / placement.width,
    cell_height = height / placement.height,
    colors = palette,
    opacity = config.options.opacity,
    line_thickness = math.max(1, config.options.insertion_line.thickness * height / placement.height),
    line_offset = config.options.insertion_line.offset * height / placement.height,
  })

  -- Switch to the other image id, since the current one is still on screen.
  self.image_slot = 3 - self.image_slot
  local id = self.image_ids[self.image_slot]

  -- Kitty gets the new image right away, while the screen still shows the previous one.
  -- The previous image is not deleted: the next draw replaces it, and deleting it now could
  -- remove it before the screen update below has moved the cells away from it.
  kitty.transmit({
    id = id,
    bytes = bytes,
    width = width,
    height = height,
    columns = placement.width,
    rows = placement.height,
  })

  -- The cells switch to the new image in the next screen update, in one frame.
  self.overlay:show(placement, cells, masks(ribbons, placement), id)
end

--- Remove the ribbon and its images.
function Connector:hide()
  if self.image_key then
    vim.iter(self.image_ids):each(kitty.delete)
  end
  self.image_key = nil

  self.overlay:hide()
end

--- Force the next draw, after the colors changed.
function Connector:invalidate() self.image_key = nil end

return M
