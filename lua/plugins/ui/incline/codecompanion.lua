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

  if current_chat then
    local chat = current_chat.chat
    if chat and chat.adapter then
      local adapter = chat.adapter

      -- Resolve model from adapter config:
      --   HTTP adapters: chat.settings.model, adapter.model.name, adapter.schema.model.default
      --   ACP adapters:  adapter.defaults.model (string or function)
      local function defaults_model()
        if adapter.defaults and adapter.defaults.model then
          return type(adapter.defaults.model) == 'function' and adapter.defaults.model(adapter)
            or adapter.defaults.model
        end
        return nil
      end

      local model = (chat and chat.settings and chat.settings['model'])
        or (type(adapter.model) == 'table' and adapter.model.name)
        or (type(adapter.model) == 'string' and adapter.model)
        or (adapter.schema and adapter.schema.model and adapter.schema.model.default)
        or defaults_model()
        or ''

      local name = adapter.formatted_name or adapter.name or ''
      title = model and ' ' .. name .. ': ' .. model .. ' ' or name
    end
  end

  if #loaded_chats > 1 and current_chat_index ~= nil then
    title = title .. current_chat_index .. '/' .. #loaded_chats .. ' '
  end

  return { { title, group = props.focused and 'FloatTitle' or 'Title' } }
end

return CodeCompanionHandler
