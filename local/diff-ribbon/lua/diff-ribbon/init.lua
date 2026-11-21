local config = require('diff-ribbon.config')
local connector = require('diff-ribbon.ui.connector')
local decorations = require('diff-ribbon.ui.decorations')
local filler = require('diff-ribbon.diff.filler')
local geometry = require('diff-ribbon.ui.geometry')
local hunks = require('diff-ribbon.diff.hunks')
local kitty = require('diff-ribbon.image.kitty')
local overlay = require('diff-ribbon.ui.overlay')
local palette = require('diff-ribbon.ui.palette')
local source = require('diff-ribbon.diff.source')

---@class DiffRibbon
local M = {}

-- Image ids spread over 24 bits so several Neovim instances in one terminal do not collide.
-- Each ribbon uses two ids, so the ids of all ribbons follow this one.
local first_image_id = 0x100000 + (vim.fn.getpid() * 7919 + vim.uv.hrtime()) % 0xEFFF00

local state = {
  -- True while the ribbons and gutter colors are on screen.
  active = false,
  -- Turned off by the user for this session, whatever `enabled` says.
  paused = false,
  -- One per pair of neighboring windows, kept between redraws.
  ---@type DiffRibbon.Connector[]
  connectors = {},
  -- Keys remember the last inputs, so unchanged work is skipped.
  ---@type string?
  hunks_key = nil,
  -- Hunks of each pair of neighboring windows, from left to right.
  ---@type DiffRibbon.Hunk[][]
  hunks = {},
  ---@type string?
  decorations_key = nil,
}

-- Groups bursts of events into one redraw.
local timer = assert(vim.uv.new_timer())

--- Connector of the pair at `index`, created on first use with its own two image ids.
---@param index integer
---@return DiffRibbon.Connector
local function connector_at(index)
  if not state.connectors[index] then
    local id = first_image_id + (index - 1) * 2
    state.connectors[index] = connector.new({ id, id + 1 })
  end
  return state.connectors[index]
end

--- Image ids of every connector, for their highlights.
---@return integer[]
local function all_image_ids()
  return vim.iter(state.connectors):fold(
    {},
    ---@param ids integer[]
    ---@param item DiffRibbon.Connector
    ---@return integer[]
    function(ids, item) return vim.list_extend(ids, item.image_ids) end
  )
end

--- Hunks of every pair, computed again only after an edit or a 'diffopt' change. With three
--- windows or more, Neovim merges the changes of all buffers into shared blocks, so each pair
--- depends on every buffer, even one stacked below that gets no ribbon.
---@param view DiffRibbon.View
---@return DiffRibbon.Hunk[][]
local function current_hunks(view)
  local buffers = vim.tbl_map(vim.api.nvim_win_get_buf, view.windows)
  local links = vim.tbl_map(
    function(pair) return { vim.fn.index(view.windows, pair.left) + 1, vim.fn.index(view.windows, pair.right) + 1 } end,
    view.pairs
  )

  local parts = vim.tbl_map(function(buffer) return buffer .. ':' .. vim.b[buffer].changedtick end, buffers)
  local link_parts = vim.tbl_map(function(link) return table.concat(link, '-') end, links)
  local key = table.concat(vim.list_extend(vim.list_extend(parts, link_parts), { vim.o.diffopt }), '|')

  if key ~= state.hunks_key then
    state.hunks = hunks.compute(buffers, links)
    state.hunks_key = key
  end

  return state.hunks
end

--- Color the gutters and underline the gaps, unless nothing changed since last time.
---@param items DiffRibbon.Decoration[]
local function decorate(items)
  -- The hunk key already changes with the buffers and their edits.
  local parts = { state.hunks_key }
  for _, item in ipairs(items) do
    table.insert(parts, table.concat({ item.pair.left, item.pair.right, vim.inspect(item.palette) }, ':'))
  end

  local key = table.concat(parts, '|')
  if key == state.decorations_key then
    return
  end
  state.decorations_key = key

  decorations.show(items)
end

--- Remove the ribbons of connectors from `first` on, all of them by default.
---@param first? integer
local function hide_ribbons(first)
  for index = first or 1, #state.connectors do
    state.connectors[index]:hide()
  end
end

--- Remove the ribbons and gutter colors, but keep the filler lines removed.
local function hide()
  hide_ribbons()
  state.decorations_key = nil
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

--- Draw the ribbon of one pair, or remove it when it has no room on screen.
---@param item DiffRibbon.Connector
---@param pair DiffRibbon.Pair
---@param hunk_list DiffRibbon.Hunk[]
---@param colors DiffRibbon.Palette
local function draw_pair(item, pair, hunk_list, colors)
  local left, right = geometry.viewport(pair.left), geometry.viewport(pair.right)
  local placement = geometry.placement(left, right, config.options.width)

  -- Kitty can only address so many rows, so taller overlays are skipped.
  if not placement or placement.height > kitty.max_cells then
    return item:hide()
  end

  item:draw(geometry.ribbons(hunk_list, left, right, placement), placement, colors)
end

--- Bring the ribbons and gutter colors in line with the current diff view.
local function render()
  local view = enabled() and source.view(config.options.layouts)
  if not view then
    return deactivate()
  end
  state.active = true
  filler.remove()

  local window_pairs = view.pairs
  local hunk_lists = current_hunks(view)
  local items = {}
  for index, pair in ipairs(window_pairs) do
    -- Each pair needs its connector before the image highlights below are set.
    connector_at(index)
    items[index] = { pair = pair, hunks = hunk_lists[index], palette = palette.resolve(pair) }
  end

  -- These read the Normal and LineNr highlights, so they run in a diff window whatever has focus.
  vim.api.nvim_win_call(window_pairs[1].right, function()
    overlay.set_images(all_image_ids())
    decorate(items)
  end)

  for index, item in ipairs(items) do
    draw_pair(state.connectors[index], item.pair, item.hunks, item.palette)
  end

  -- A layout with fewer windows than before leaves ribbons that no longer have a pair.
  hide_ribbons(#window_pairs + 1)
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
      vim.iter(state.connectors):each(
        ---@param item DiffRibbon.Connector
        function(item) item:invalidate() end
      )
      state.decorations_key = nil
      overlay.reset_highlights()
      M.refresh()
    end,
  })

  -- Put 'diffopt' back and clear the images before Neovim quits.
  vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = deactivate })
end

return M
