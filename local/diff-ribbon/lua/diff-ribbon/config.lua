---@class DiffRibbon.Config
---@field enabled boolean|fun(): boolean
---@field width integer Overlay columns, centered on the separator between both windows
---@field layouts string[] diffview-plus layouts that get ribbons
---@field opacity number Ribbon opacity from 0 to 1
---@field debounce integer Milliseconds between redraws
---@field cell_size? DiffRibbon.CellSize Pixel size of one cell when the terminal cannot report it
---@field colors table<DiffRibbon.Kind, string[]> Highlight groups whose background colors each kind, first match wins, looked up in the window that shows those lines
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

---@class DiffRibbon.ConfigModule
---@field options DiffRibbon.Config
local M = {}

---@type DiffRibbon.Config
local defaults = {
  -- A container does not see the Kitty variables, but it is expected to run inside Kitty on the host.
  enabled = function() return (vim.env.KITTY_WINDOW_ID or vim.env.INSIDE_DOCKER) ~= nil and vim.env.TMUX == nil end,
  width = 5,
  -- Above scrollbars such as satellite.nvim (40), below popups and terminals (50 and up).
  zindex = 45,
  -- Layouts with windows side by side. Stacked windows in the mixed ones get no ribbon.
  layouts = { 'diff2_horizontal', 'diff2_horizontal_pinned', 'diff3_horizontal', 'diff3_mixed', 'diff4_mixed' },
  opacity = 1,
  debounce = 16,
  -- Lines that only one side has are drawn with DiffAdd in that window. diffview-plus remaps it to
  -- its deletion color in the left window of two way diffs, so deletions match it there.
  colors = {
    add = { 'DiffAdd' },
    delete = { 'DiffAdd' },
    change = { 'DiffChange' },
  },
  -- A terminal underline is about one eighteenth of a row thick, drawn just above the row boundary.
  insertion_line = { thickness = 1 / 18, offset = 1 / 18 },
}

M.options = defaults

--- Merge the user options over the defaults, so calling it again starts from scratch.
---@param options? DiffRibbon.Options
function M.setup(options) M.options = vim.tbl_deep_extend('force', defaults, options or {}) end

return M
