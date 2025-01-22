local constants = require('overseer.constants')

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
    local methods = {}

    methods.on_start = function(self, task)
      -- Only open on start if the current overseer window is visible
      local window = require('overseer.window')
      if window.is_open() then
        open_output(task, params.direction, params.focus)
      end
    end

    return methods
  end,
}

return comp
