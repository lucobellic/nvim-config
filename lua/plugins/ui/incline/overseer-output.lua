local Handler = require('plugins.ui.incline.handler')

---@class OverseerOutputHandler : InclineHandler
local OverseerOutputHandler = Handler:new({ filetype = 'OverseerOutput' })

function OverseerOutputHandler:render(props)
  local task_id = vim.b[props.buf].overseer_task
  local title = ' overseer '
  if task_id and task_id ~= -1 then
    local ok, task = pcall(require('overseer.task_list').get, task_id)
    if ok and task and task.name then
      title = ' ' .. task.name .. ' '
    end
  end
  return { { title, group = props.focused and 'FloatTitle' or 'Title' } }
end

return OverseerOutputHandler
