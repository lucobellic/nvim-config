local Handler = require('plugins.ui.incline.handler')

---@class SnacksTerminalHandler : InclineHandler
local SnacksTerminalHandler = Handler:new({ filetype = 'snacks_terminal' })

function SnacksTerminalHandler:render(props)
  local terminals = vim
    .iter(vim.api.nvim_list_bufs())
    :filter(function(buf) return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'snacks_terminal' end)
    :totable()

  local current = vim.iter(terminals):enumerate():filter(function(_, buf) return buf == props.buf end):next() or 0
  local id = ' ' .. current .. '/' .. #terminals .. ' '
  return { { id, group = props.focused and 'FloatTitle' or 'Title' } }
end

return SnacksTerminalHandler
