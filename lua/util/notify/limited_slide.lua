local stages_util = require('notify.stages.util')

-- top_down, bottom_up, left_right, right_left
local direction = 'bottom_up'
local max_nb_messages = 3

return {
  function(state)
    local next_height = state.message.height + 2
    local next_row = stages_util.available_slot(state.open_windows, next_height, direction)
    local max_messages_reached = #state.open_windows >= max_nb_messages
    if not next_row or max_messages_reached then
      return nil
    end
    local bottom_row = vim.opt.lines:get() - next_height
    -- Add a shift to get notification above lua line
    next_row = next_row == bottom_row and next_row - 1 or next_row
    return {
      relative = 'editor',
      anchor = 'NE',
      width = state.message.width,
      height = state.message.height,
      col = vim.opt.columns:get(),
      row = next_row,
      border = vim.g.border,
      style = 'minimal',
      opacity = 0,
    }
  end,
  function(state, win)
    return {
      opacity = { 100 },
      col = { vim.opt.columns:get() },
      row = {
        stages_util.slot_after_previous(win, state.open_windows, direction),
        frequency = 3,
        complete = function() return true end,
      },
    }
  end,
  function(state, win)
    return {
      col = { vim.opt.columns:get() },
      time = true,
      row = {
        stages_util.slot_after_previous(win, state.open_windows, direction),
        frequency = 3,
        complete = function() return true end,
      },
    }
  end,
  function(state, win)
    return {
      width = {
        1,
        frequency = 2.5,
        damping = 0.9,
        complete = function(cur_width) return cur_width < 3 end,
      },
      opacity = {
        0,
        frequency = 2,
        complete = function(cur_opacity) return cur_opacity <= 4 end,
      },
      col = { vim.opt.columns:get() },
      row = {
        stages_util.slot_after_previous(win, state.open_windows, direction),
        frequency = 3,
        complete = function() return true end,
      },
    }
  end,
}
