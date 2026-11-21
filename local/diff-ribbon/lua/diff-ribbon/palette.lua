---@alias DiffRibbon.Palette table<DiffRibbon.Kind, integer[]?>

local config = require('diff-ribbon.config')

local M = {}

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

--- Colors per change kind, each looked up in the window that shows those lines: deleted lines sit
--- in the left window, added and changed lines in the right one. Highlight lookups follow that
--- window's 'winhighlight', so the ribbon matches the line colors it touches, whatever has focus.
---@param pair DiffRibbon.Pair
---@return DiffRibbon.Palette
function M.resolve(pair)
  return vim.iter(config.options.colors):fold({}, function(result, kind, groups)
    local window = kind == 'delete' and pair.left or pair.right
    result[kind] = vim.api.nvim_win_call(window, function() return background(groups) end)
    return result
  end)
end

return M
