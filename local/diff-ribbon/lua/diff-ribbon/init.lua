---@class DiffRibbon.Config
---@field enabled boolean|fun(): boolean
---@field width integer Overlay columns, centered on the separator between both windows
---@field layouts string[] diffview-plus layouts that get ribbons
---@field opacity number Ribbon opacity from 0 to 1
---@field debounce integer Milliseconds between redraws
---@field cell_size? DiffRibbon.CellSize Pixel size of one cell when the terminal cannot report it
---@field colors table<DiffRibbon.Kind, string[]> Highlight groups whose background colors each kind, first match wins
---@field insertion_line { thickness: number, offset: number } Underline size and gap above the row boundary, in fractions of a row
---@field zindex integer Stacking order of the ribbon overlay among floating windows

--- User options given to `setup`, merged over the defaults.
---@class DiffRibbon.Options
---@field enabled? boolean|fun(): boolean
---@field width? integer
---@field layouts? string[]
---@field opacity? number
---@field debounce? integer
---@field cell_size? DiffRibbon.CellSize
---@field colors? table<DiffRibbon.Kind, string[]>
---@field insertion_line? { thickness: number, offset: number }
---@field zindex? integer

local decorations = require('diff-ribbon.decorations')
local filler = require('diff-ribbon.filler')
local geometry = require('diff-ribbon.geometry')
local hunks = require('diff-ribbon.hunks')
local kitty = require('diff-ribbon.kitty')
local overlay = require('diff-ribbon.overlay')
local raster = require('diff-ribbon.raster')
local source = require('diff-ribbon.source')

---@class DiffRibbon
local M = {}

---@type DiffRibbon.Config
local defaults = {
  -- A container does not see the Kitty variables, but it is expected to run inside Kitty on the host.
  enabled = function() return (vim.env.KITTY_WINDOW_ID or vim.env.INSIDE_DOCKER) ~= nil and vim.env.TMUX == nil end,
  width = 5,
  -- Above scrollbars such as satellite.nvim (40), below popups and terminals (50 and up).
  zindex = 45,
  layouts = { 'diff2_horizontal' },
  opacity = 1,
  debounce = 16,
  colors = {
    add = { 'DiffAdd' },
    delete = { 'DiffviewDiffAddAsDelete', 'DiffDelete' },
    change = { 'DiffChange' },
  },
  -- A terminal underline is about one eighteenth of a row thick, drawn just above the row boundary.
  insertion_line = { thickness = 1 / 18, offset = 1 / 18 },
}

---@type DiffRibbon.Config
local config = defaults

-- Image ids spread over 24 bits so several Neovim instances in one terminal do not collide.
-- Two images take turns: the next one loads while the current one stays on screen, so the
-- switch happens in a single screen update instead of showing a half updated ribbon.
local first_image_id = 0x100000 + (vim.fn.getpid() * 7919 + vim.uv.hrtime()) % 0xEFFFFE
local image_ids = { first_image_id, first_image_id + 1 }

local state = {
  active = false,
  -- Index in `image_ids` of the image the overlay shows.
  image_slot = 1,
  -- Turned off by the user for this session, whatever `enabled` says.
  paused = false,
  ---@type string?
  hunks_key = nil,
  ---@type DiffRibbon.Hunk[]
  hunks = {},
  ---@type string?
  image_key = nil,
  ---@type string?
  decorations_key = nil,
}

local timer = assert(vim.uv.new_timer())

---@param groups string[]
---@return integer[]?
local function background(groups)
  local color = vim
    .iter(groups)
    :map(function(group) return vim.api.nvim_get_hl(0, { name = group, link = false }).bg end)
    :next()
  return color
    and { bit.band(bit.rshift(color, 16), 0xFF), bit.band(bit.rshift(color, 8), 0xFF), bit.band(color, 0xFF) }
end

---@return table<DiffRibbon.Kind, integer[]?>
local function colors()
  return vim.iter(config.colors):fold({}, function(result, kind, groups)
    result[kind] = background(groups)
    return result
  end)
end

---@param pair DiffRibbon.Pair
---@return DiffRibbon.Hunk[]
local function current_hunks(pair)
  local left, right = vim.api.nvim_win_get_buf(pair.left), vim.api.nvim_win_get_buf(pair.right)
  local key = table.concat({ left, vim.b[left].changedtick, right, vim.b[right].changedtick, vim.o.diffopt }, ':')
  if key ~= state.hunks_key then
    state.hunks = hunks.compute(left, right)
    state.hunks_key = key
  end
  return state.hunks
end

---@param ribbons DiffRibbon.Ribbon[]
---@param placement DiffRibbon.Placement
---@param palette table<DiffRibbon.Kind, integer[]?>
---@return string
local function image_key(ribbons, placement, palette)
  local parts = vim
    .iter(ribbons)
    :map(
      function(ribbon)
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
  if bottom <= top then
    first, last = top - 1, top - 1
  end
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
  vim.iter(ribbons):each(function(ribbon)
    mark_side(result.left, ribbon.left_top, ribbon.left_bottom, placement.height)
    mark_side(result.right, ribbon.right_top, ribbon.right_bottom, placement.height)
  end)
  result.center = vim.tbl_extend('force', result.left, result.right)
  return result
end

---@param ribbons DiffRibbon.Ribbon[]
---@param placement DiffRibbon.Placement
local function draw(ribbons, placement)
  local palette = colors()
  local key = image_key(ribbons, placement, palette)
  if key == state.image_key then
    return
  end
  state.image_key = key
  local cell = kitty.cell_size() or config.cell_size or { width = 10, height = 20 }
  local width, height = math.floor(placement.width * cell.width), math.floor(placement.height * cell.height)
  local bytes, cells = raster.render(ribbons, {
    width = width,
    height = height,
    cell_width = width / placement.width,
    cell_height = height / placement.height,
    colors = palette,
    opacity = config.opacity,
    line_thickness = math.max(1, config.insertion_line.thickness * height / placement.height),
    line_offset = config.insertion_line.offset * height / placement.height,
  })
  state.image_slot = 3 - state.image_slot
  local id = image_ids[state.image_slot]
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
  overlay.show(placement, cells, masks(ribbons, placement), id)
end

---@param pair DiffRibbon.Pair
---@param hunk_list DiffRibbon.Hunk[]
local function decorate(pair, hunk_list)
  local palette = colors()
  local key = table.concat({ state.hunks_key, pair.left, pair.right, vim.inspect(palette) }, '|')
  if key == state.decorations_key then
    return
  end
  state.decorations_key = key
  decorations.set_colors(palette)
  decorations.show(pair, hunk_list)
end

local function hide()
  if state.image_key then
    vim.iter(image_ids):each(kitty.delete)
  end
  state.image_key = nil
  state.decorations_key = nil
  overlay.hide()
  decorations.clear()
end

local function deactivate()
  if not state.active then
    return
  end
  state.active = false
  hide()
  filler.restore()
end

---@return boolean
local function enabled()
  if state.paused then
    return false
  end
  local value = config.enabled
  if type(value) == 'function' then
    value = value()
  end
  return value and vim.o.termguicolors and vim.api.nvim_ui_send ~= nil
end

local function render()
  local pair = enabled() and source.pair(config.layouts)
  if not pair then
    return deactivate()
  end
  state.active = true
  filler.remove()
  local left, right = geometry.viewport(pair.left), geometry.viewport(pair.right)
  local placement = geometry.placement(left, right, config.width)
  if not placement or placement.height > kitty.max_cells then
    return hide()
  end
  local hunk_list = current_hunks(pair)
  decorate(pair, hunk_list)
  overlay.set_images(image_ids)
  draw(geometry.ribbons(hunk_list, left, right, placement), placement)
end

--- Schedule a redraw. Many events arrive together while scrolling, so they share one redraw.
function M.refresh() timer:start(config.debounce, 0, vim.schedule_wrap(render)) end

--- Turn the ribbons, gutter colors and filler removal off or back on.
---@return boolean on
function M.toggle()
  state.paused = not state.paused
  M.refresh()
  return not state.paused
end

---@param options? DiffRibbon.Options
function M.setup(options)
  config = vim.tbl_deep_extend('force', defaults, options or {})
  overlay.zindex = config.zindex
  local group = vim.api.nvim_create_augroup('diff-ribbon', { clear = true })
  -- Scrolling and resizing draw right away: these events run just before Neovim draws the screen,
  -- so the text and the ribbon move in the same frame instead of the ribbon lagging behind.
  vim.api.nvim_create_autocmd({ 'WinScrolled', 'WinResized' }, {
    group = group,
    callback = function()
      timer:stop()
      render()
    end,
  })
  vim.api.nvim_create_autocmd({
    'WinEnter',
    'WinClosed',
    'TabEnter',
    'BufWinEnter',
    'DiffUpdated',
    'TextChanged',
    'TextChangedI',
    'VimResized',
  }, { group = group, callback = M.refresh })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      state.image_key = nil
      state.decorations_key = nil
      overlay.reset_highlights()
      M.refresh()
    end,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = deactivate })
end

return M
