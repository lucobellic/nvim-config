-- Module for integrating Copilot o1 models as a code completion provider in CodeCompanion
local M = {}

---Helper function to parse the response data from Copilot
---@param data string Raw data received from Copilot
---@return table|nil
local function parse_data(data)
  if data and data ~= '' then
    -- Remove leading 'data: ' if present
    local data_mod = data:sub(1, 6) == 'data: ' and data:sub(7) or data
    local ok, json = pcall(vim.json.decode, data_mod, { luanil = { object = true } })
    if ok and json then
      return json
    end
  end
  return nil
end

---Get the Copilot adapter for CodeCompanion
---@return CodeCompanion.Adapter adapter configured for Copilot using o1 models
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

      ---Handler for processing chat output from Copilot
      ---@param data string Raw data received from Copilot
      ---@return table|nil
      chat_output = function(data)
        local output = {}
        local json = parse_data(data)
        if json and #json.choices > 0 then
          local choice = json.choices[1]
          local delta = choice.delta or choice.message
          if delta.content then
            output.content = delta.content
            output.role = delta.role or nil
            return {
              status = 'success',
              output = output,
            }
          end
        end
      end,

      ---Handler for processing inline output from Copilot
      ---@param data string Raw data received from Copilot
      ---@param context table
      ---@return string|nil
      inline_output = function(data, context)
        local json = parse_data(data)
        if json and #json.choices > 0 then
          local choice = json.choices[1]
          local delta = choice.delta or choice.message
          if delta.content then
            return delta.content
          end
        end
      end,
    },
  })

  -- Remove unsupported settings from the adapter schema
  local unsupported_settings = { 'temperature', 'max_tokens', 'top_p', 'n' }
  vim.iter(unsupported_settings):each(function(setting) adapter.schema[setting] = nil end)

  return adapter
end

return M
