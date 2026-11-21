local config = require('diff-ribbon.config')
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

-- Image ids spread over 24 bits so several Neovim instances in one terminal do not collide.
-- Two images take turns: the next one loads while the current one stays on screen, so the
-- switch happens in a single screen update instead of showing a half updated ribbon.
local first_image_id = 0x100000 + (vim.fn.getpid() * 7919 + vim.uv.hrtime()) % 0xEFFFFE
local image_ids = { first_image_id, first_image_id + 1 }

local state = {
  -- True while the ribbons and gutter colors are on screen.
  active = false,
  -- Index in `image_ids` of the image the overlay shows.
  image_slot = 1,
  -- Turned off by the user for this session, whatever `enabled` says.
  paused = false,
  -- Keys remember the last inputs, so unchanged work is skipped.
  ---@type string?
  hunks_key = nil,
  ---@type DiffRibbon.Hunk[]
  hunks = {},
  ---@type string?
  image_key = nil,
  ---@type string?
  decorations_key = nil,
}

-- Groups bursts of events into one redraw.
local timer = assert(vim.uv.new_timer())

--- RGB background of the first group that has one.
---@param groups string[]
---@return integer[]?
local function background(groups)
  local color = vim
    .iter(groups)
    :map(
      ---@param group string
      ---@return integer?
      function(group)
        ---@diagnostic disable-next-line: missing-return-value
        return vim.api.nvim_get_hl(0, { name = group, link = false }).bg
      end
    )
    :next()

  -- Split the color into red, green and blue for the image.
  return color
    and { bit.band(bit.rshift(color, 16), 0xFF), bit.band(bit.rshift(color, 8), 0xFF), bit.band(color, 0xFF) }
end

--- Colors per change kind, the same whichever side has focus. Highlight lookups follow the current
--- window's 'winhighlight', and diffview remaps DiffAdd to its deletion color on the left side,
--- so the lookup always runs in the right window.
---@param pair DiffRibbon.Pair
---@return table<DiffRibbon.Kind, integer[]?>
local function colors(pair)
  return vim.api.nvim_win_call(pair.right, function()
    return vim.iter(config.options.colors):fold({}, function(result, kind, groups)
      result[kind] = background(groups)
      return result
    end)
  end)
end

--- Hunks of both buffers, computed again only after an edit or a 'diffopt' change.
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

--- Text that changes whenever the image would look different.
---@param ribbons DiffRibbon.Ribbon[]
---@param placement DiffRibbon.Placement
---@param palette table<DiffRibbon.Kind, integer[]?>
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
---@param palette table<DiffRibbon.Kind, integer[]?>
local function draw(ribbons, placement, palette)
  local key = image_key(ribbons, placement, palette)
  if key == state.image_key then
    return
  end
  state.image_key = key

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

--- Color the gutters of both windows, unless nothing changed since last time.
---@param pair DiffRibbon.Pair
---@param hunk_list DiffRibbon.Hunk[]
---@param palette table<DiffRibbon.Kind, integer[]?>
local function decorate(pair, hunk_list, palette)
  local key = table.concat({ state.hunks_key, pair.left, pair.right, vim.inspect(palette) }, '|')
  if key == state.decorations_key then
    return
  end
  state.decorations_key = key

  decorations.set_colors(palette)
  decorations.show(pair, hunk_list)
end

--- Remove the ribbons and gutter colors, but keep the filler lines removed.
local function hide()
  if state.image_key then
    vim.iter(image_ids):each(kitty.delete)
  end
  state.image_key = nil
  state.decorations_key = nil

  overlay.hide()
  decorations.clear()
end

--- Leave the diff as Neovim draws it without the plugin.
local function deactivate()
  if not state.active then
    return
  end
  state.active = false

  hide()
  filler.restore()
end

--- Whether the user and the terminal allow ribbons right now.
---@return boolean
local function enabled()
  if state.paused then
    return false
  end

  local value = config.options.enabled
  if type(value) == 'function' then
    value = value()
  end

  -- Ribbons need true colors and a Neovim that can send raw terminal codes.
  return value and vim.o.termguicolors and vim.api.nvim_ui_send ~= nil
end

--- Bring the ribbons and gutter colors in line with the current diff view.
local function render()
  local pair = enabled() and source.pair(config.options.layouts)
  if not pair then
    return deactivate()
  end
  state.active = true
  filler.remove()

  local left, right = geometry.viewport(pair.left), geometry.viewport(pair.right)
  local placement = geometry.placement(left, right, config.options.width)
  -- Kitty can only address so many rows, so taller overlays are skipped.
  if not placement or placement.height > kitty.max_cells then
    return hide()
  end

  local hunk_list = current_hunks(pair)
  local palette = colors(pair)

  -- These also read highlights (Normal, LineNr), so they use the right window too, whatever has focus.
  vim.api.nvim_win_call(pair.right, function()
    decorate(pair, hunk_list, palette)
    overlay.set_images(image_ids)
  end)

  draw(geometry.ribbons(hunk_list, left, right, placement), placement, palette)
end

--- Schedule a redraw. Many events arrive together while scrolling, so they share one redraw.
function M.refresh() timer:start(config.options.debounce, 0, vim.schedule_wrap(render)) end

--- Turn the ribbons, gutter colors and filler removal off or back on.
---@return boolean on
function M.toggle()
  state.paused = not state.paused
  M.refresh()
  return not state.paused
end

---@param options? DiffRibbon.Options
function M.setup(options)
  config.setup(options)

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

  -- Other changes to the view or the text can wait for the shared redraw.
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

  -- New colors need a new image and new gutter highlights.
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      state.image_key = nil
      state.decorations_key = nil
      overlay.reset_highlights()
      M.refresh()
    end,
  })

  -- Put 'diffopt' back and clear the images before Neovim quits.
  vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = deactivate })
end

return M
