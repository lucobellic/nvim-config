local Handler = require('plugins.ui.incline.handler')

---@class CodeCompanionHandler : InclineHandler
local CodeCompanionHandler = Handler:new({ filetype = 'codecompanion' })

function CodeCompanionHandler:render(props)
  local title = ' codecompanion '
  local codecompanion = require('codecompanion')

  --- @type CodeCompanion.Chat[]
  local loaded_chats = codecompanion.buf_get_chat()

  --- @type number?, { chat: CodeCompanion.Chat? }?
  local current_chat_index, current_chat = vim
    .iter(ipairs(loaded_chats))
    :filter(function(_, chat_table) return chat_table.chat.bufnr == props.buf end)
    :nth(1)

  if current_chat and current_chat.chat then
    local model = current_chat.chat.settings and current_chat.chat.settings['model'] or ''
    local adapter_name = current_chat.chat.adapter.name
    title = model and ' ' .. adapter_name .. ': ' .. model .. ' ' or adapter_name
  end

  if #loaded_chats > 1 and current_chat_index ~= nil then
    title = title .. current_chat_index .. '/' .. #loaded_chats .. ' '
  end

  return { { title, group = props.focused and 'FloatTitle' or 'Title' } }
end

return CodeCompanionHandler
