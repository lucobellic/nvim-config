---@class DiffRibbon.Image
---@field width integer Pixels
---@field height integer Pixels
---@field cell_width number Pixels per column
---@field cell_height number Pixels per text row
---@field colors table<DiffRibbon.Kind, integer[]?> RGB per kind
---@field opacity number
---@field line_thickness number Pixels of the insertion line, matching the terminal underline
---@field line_offset number Pixels between the insertion line bottom and the row boundary below it

--- Cells holding ribbon pixels, as `cells[row][column] = true`, both 0 based.
---@alias DiffRibbon.Cells table<integer, table<integer, true>>

local ffi = require('ffi')

local M = {}

local SUBSAMPLES = 4
-- Bezier control point position used by JetBrains for its diff divider.
local CONTROL = 0.3

---@param t number
---@return number
local function bezier_x(t)
  local u = 1 - t
  return 3 * CONTROL * u * u * t + 3 * (1 - CONTROL) * u * t * t + t * t * t
end

--- Vertical progress (0 to 1) of a ribbon edge at a horizontal fraction of the width.
---@param fraction number
---@return number
local function progress(fraction)
  local low, high = 0, 1
  for _ = 1, 30 do
    local middle = (low + high) / 2
    if bezier_x(middle) < fraction then
      low = middle
    else
      high = middle
    end
  end
  local t = (low + high) / 2
  return 3 * t * t - 2 * t * t * t
end

---@type table<integer, number[]>
local shapes = {}

---@param width integer
---@return number[]
local function shape(width)
  if not shapes[width] then
    local samples = width * SUBSAMPLES
    shapes[width] = vim
      .iter(vim.fn.range(samples))
      :map(function(index) return progress((index + 0.5) / samples) end)
      :totable()
  end
  return shapes[width]
end

---@param top number
---@param bottom number
---@param thickness number
---@return number, number
local function thicken(top, bottom, thickness)
  if bottom - top >= thickness then
    return top, bottom
  end
  local middle = (top + bottom) / 2
  return middle - thickness / 2, middle + thickness / 2
end

--- Pixel extent of one side. An empty side is drawn where the terminal draws the underline
--- of the line above, so the ribbon continues the underline in the buffer.
---@param image DiffRibbon.Image
---@param top number Rows
---@param bottom number Rows
---@return number, number
local function side_extent(image, top, bottom)
  if bottom > top then
    return top * image.cell_height, bottom * image.cell_height
  end
  local line_bottom = top * image.cell_height - image.line_offset
  return line_bottom - image.line_thickness, line_bottom
end

--- Straight alpha source over blend of an opaque color.
---@param pixels ffi.cdata*
---@param index integer
---@param color integer[]
---@param alpha number
local function blend(pixels, index, color, alpha)
  if alpha <= 0 then
    return
  end
  local below = pixels[index + 3] / 255 * (1 - alpha)
  local total = alpha + below
  for channel = 0, 2 do
    pixels[index + channel] = math.floor((color[channel + 1] * alpha + pixels[index + channel] * below) / total + 0.5)
  end
  pixels[index + 3] = math.floor(total * 255 + 0.5)
end

---@param tops number[]
---@param bottoms number[]
---@param row integer
---@return number
local function coverage(tops, bottoms, row)
  local covered = 0
  for sample = 1, SUBSAMPLES do
    covered = covered + math.max(0, math.min(bottoms[sample], row + 1) - math.max(tops[sample], row))
  end
  return covered / SUBSAMPLES
end

---@param cells DiffRibbon.Cells
---@param image DiffRibbon.Image
---@param x integer
---@param y integer
local function mark(cells, image, x, y)
  local row = math.floor(y / image.cell_height)
  cells[row] = cells[row] or {}
  cells[row][math.floor(x / image.cell_width)] = true
end

---@param pixels ffi.cdata*
---@param cells DiffRibbon.Cells
---@param image DiffRibbon.Image
---@param ribbon DiffRibbon.Ribbon
---@param color integer[]
local function fill(pixels, cells, image, ribbon, color)
  local edges = shape(image.width)
  local thickness = image.line_thickness
  local left_top, left_bottom = side_extent(image, ribbon.left_top, ribbon.left_bottom)
  local right_top, right_bottom = side_extent(image, ribbon.right_top, ribbon.right_bottom)
  local tops, bottoms = {}, {}
  for x = 0, image.width - 1 do
    for sample = 1, SUBSAMPLES do
      local step = edges[x * SUBSAMPLES + sample]
      tops[sample], bottoms[sample] =
        thicken(left_top + (right_top - left_top) * step, left_bottom + (right_bottom - left_bottom) * step, thickness)
    end
    local first = math.max(0, math.floor(math.min(unpack(tops))))
    local last = math.min(image.height - 1, math.ceil(math.max(unpack(bottoms))) - 1)
    for y = first, last do
      local alpha = coverage(tops, bottoms, y) * image.opacity
      if alpha > 0 then
        blend(pixels, (y * image.width + x) * 4, color, alpha)
        mark(cells, image, x, y)
      end
    end
  end
end

--- Draw the ribbons into raw RGBA bytes, and report which cells they touch.
---@param ribbons DiffRibbon.Ribbon[]
---@param image DiffRibbon.Image
---@return string bytes
---@return DiffRibbon.Cells cells
function M.render(ribbons, image)
  local size = image.width * image.height * 4
  local pixels = ffi.new('uint8_t[?]', size)
  local cells = {}
  vim.iter(ribbons):each(function(ribbon)
    local color = image.colors[ribbon.kind]
    if color then
      fill(pixels, cells, image, ribbon, color)
    end
  end)
  return ffi.string(pixels, size), cells
end

return M
