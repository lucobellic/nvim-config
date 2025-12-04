local Popup = require('nui.popup')
local config = require('util.term.config')

---@class TermManagerUI
local M = {}

--- Highlight rotation for terminal borders
local HIGHLIGHTS = { 'TelescopePromptTitle', 'TelescopeResultsTitle', 'TelescopePreviewTitle' }

--- Get highlight for terminal index
---@param index integer
---@return string
function M.get_highlight(index) return HIGHLIGHTS[((index - 1) % 3) + 1] end

--- Generate terminal sequence for border (e.g., "1 2 3" with current highlighted)
---@param current_index integer
---@param terminal_count integer
---@return table[] border_text
function M.generate_sequence(current_index, terminal_count)
  local parts = {}
  for i = 1, terminal_count do
    if i > 1 then
      table.insert(parts, { ' ', 'FloatBorder' })
    end
    local hl = i == current_index and M.get_highlight(current_index) or 'FloatBorder'
    table.insert(parts, { ' ' .. tostring(i) .. ' ', hl })
  end
  return parts
end

--- Update border title and sequence
---@param popup NuiPopup
---@param term Term
---@param terminal_count integer
function M.update_border(popup, term, terminal_count)
  if not popup or not popup.border then
    return
  end

  -- Update top border with terminal title showing current/total
  local title_hl = M.get_highlight(term.index)
  -- Use terminal's title if set, otherwise use 'Terminal' for auto-numbered ones
  local display_name = (term.opts and term.opts.title) or 'Terminal'
  local title = string.format(' %s %d/%d ', display_name, term.index, terminal_count)
  popup.border:set_text('top', { { title, title_hl } }, 'center')

  -- Update bottom border with terminal sequence
  local sequence = M.generate_sequence(term.index, terminal_count)
  popup.border:set_text('bottom', sequence, 'center')
end

--- Create popup window for terminal display
---@return NuiPopup
function M.create_popup()
  local cfg = config.get()

  -- Calculate size (keep as relative values for Nui)
  local width = cfg.defaults.width or 0.6
  local height = cfg.defaults.height or 0.6

  -- Create popup
  ---@diagnostic disable-next-line: missing-fields
  return Popup({
    enter = true,
    focusable = true,
    relative = 'editor',
    position = '50%',
    size = {
      width = width,
      height = height,
    },
    border = {
      style = config.get_border_style(),
      text = {
        top = ' Terminal ',
        top_align = 'center',
        bottom_align = 'center',
      },
    },
    win_options = {
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
      sidescrolloff = 0,
    },
    zindex = cfg.defaults.zindex or 50,
  })
end

return M
