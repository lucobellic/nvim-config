local stages_util = require("notify.stages.util")

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
    return {
      relative = "editor",
      anchor = "NE",
      width = 1,
      height = state.message.height,
      col = vim.opt.columns:get(),
      row = next_row,
      border = "rounded",
      style = "minimal",
    }
  end,
  function(state)
    return {
      width = { state.message.width, frequency = 2 },
      col = { vim.opt.columns:get() },
    }
  end,
  function()
    return {
      col = { vim.opt.columns:get() },
      time = true,
    }
  end,
  function()
    return {
      width = {
        1,
        frequency = 2.5,
        damping = 0.9,
        complete = function(cur_width)
          return cur_width < 2
        end,
      },
      col = { vim.opt.columns:get() },
    }
  end,
}
