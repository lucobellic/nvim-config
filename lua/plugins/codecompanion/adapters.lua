local chat_adapter = 'copilot'
local agent_adapter = 'copilot'
local inline_adapter = 'copilot_inline'

return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      chat = { adapter = chat_adapter },
      inline = { adapter = inline_adapter },
      agent = { adapter = agent_adapter },
    },
    adapters = {
      copilot = function()
        return require('codecompanion.adapters').extend('copilot', {
          schema = { model = { default = 'claude-3.7-sonnet' } },
        })
      end,
      copilot_inline = function()
        return require('codecompanion.adapters').extend('copilot', {
          schema = { model = { default = 'claude-3.7-sonnet' } },
        })
      end,
      ollama = function()
        return require('codecompanion.adapters').extend('ollama', {
          schema = {
            model = {
              default = 'deepseek-coder-v2',
              choices = {
                'deepseek-coder-v2',
                'deepseek-r1',
              },
            },
          },
        })
      end,
    },
  },
}
