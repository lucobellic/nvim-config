local M = {}

--- Returns a configured adapter for Copilot o1 models.
---
--- This adapter is specifically tailored for Copilot's o1 models, setting appropriate
--- parameters, adjusting the schema, and defining custom handlers to ensure compatibility.
---
---@return CodeCompanion.Adapter adapter A configured adapter for Copilot o1 models.
function M.get_adapter()
  local adapters = require('codecompanion.adapters')

  -- Extend the Copilot adapter with specific parameters and handlers for o1 models
  local adapter = adapters.extend('copilot', {
    parameters = { stream = false }, -- Stream not supported
    schema = {
      model = {
        default = 'o1-preview',
        choices = {
          'o1-preview',
          'o1-mini',
        },
      },
    },
    handlers = {
      ---Handler to remove system prompt from messages
      ---@param self CodeCompanion.Adapter
      ---@param messages table
      form_messages = function(self, messages)
        return {
          messages = vim
            .iter(messages)
            :filter(function(message) return not (message.role and message.role == 'system') end)
            :totable(),
        }
      end,
    },
  })

  -- Remove unsupported settings from the adapter schema
  local unsupported_settings = { 'temperature', 'max_tokens', 'top_p', 'n' }
  vim.iter(unsupported_settings):each(function(setting) adapter.schema[setting] = nil end)

  adapter.name = 'copilot_o1'
  return adapter
end

return M
