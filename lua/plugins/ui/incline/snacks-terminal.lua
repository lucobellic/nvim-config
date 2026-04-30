local Handler = require('plugins.ui.incline.handler')

---@class SnacksTerminalHandler : InclineHandler
local SnacksTerminalHandler = Handler:new({ filetype = 'snacks_terminal' })

function SnacksTerminalHandler:render(props)
  local id = ' ' .. vim.fn.bufname(props.buf):sub(-1) .. ' '
  return { { id, group = props.focused and 'FloatTitle' or 'Title' } }
end

return SnacksTerminalHandler
