---@param task overseer.Task
---@param direction "dock"|"float"|"tab"|"vertical"|"horizontal"
---@param focus boolean
local function open_output(task, direction, focus)
  if direction == 'dock' then
    local window = require('overseer.window')
    window.open({
      direction = 'bottom',
      enter = focus,
      focus_task_id = task.id,
    })
  else
    local winid = vim.api.nvim_get_current_win()
    ---@cast direction "float"|"tab"|"vertical"|"horizontal"
    task:open_output(direction)
    if not focus then
      vim.api.nvim_set_current_win(winid)
    end
  end
end

local function is_buffer_visible(bufnr)
  return vim
    .iter(vim.api.nvim_list_wins())
    :any(function(win) return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr end)
end

---@type overseer.ComponentFileDefinition
local comp = {
  desc = 'Open task output',
  params = {
    direction = {
      desc = 'Where to open the task output',
      type = 'enum',
      choices = { 'dock', 'float', 'tab', 'vertical', 'horizontal' },
      default = 'dock',
      long_desc = "The 'dock' option will open the output docked to the bottom next to the task list.",
    },
    focus = {
      desc = 'Focus the output window when it is opened',
      type = 'boolean',
      default = false,
    },
  },
  constructor = function(params)
    ---@type overseer.ComponentSkeleton
    return {
      on_start = function(_, task)
        local window = require('overseer.window')
        local bufnr = task:get_bufnr()
        local already_visible = bufnr ~= nil and is_buffer_visible(bufnr)
        if not already_visible and window.is_open() then
          open_output(task, params.direction, params.focus)
        end
      end,
    }
  end,
}

return comp
