---@type CodeCompanion.Interactions
local interactions = vim.env.INSIDE_DOCKER
    and {
      cmd = { adapter = 'cursor_cli', model = 'Auto' },
      chat = { adapter = 'cursor_cli', model = 'Auto' },
      inline = { adapter = 'cursor_cli', model = 'Auto' },
    }
  or {
    cmd = { adapter = { name = 'opencode', model = 'opencode-go/deepseek-v4-flash' } },
    chat = { adapter = { name = 'opencode', model = 'opencode-go/deepseek-v4-flash' } },
    inline = { adapter = { name = 'cocodex', model = 'gpt-5.4-mini' } },
  }

return {
  'olimorris/codecompanion.nvim',
  opts = {
    ---@type CodeCompanion.Adapters
    adapters = {
      http = {
        cocodex = function() return require('plugins.ai.codecompanion.adapters.http.codex') end,
      },
      copilot = function()
        return require('codecompanion.adapters').extend('copilot', {
          schema = { model = { default = 'gpt-5-mini' } },
        })
      end,
      acp = {
        cursor_cli = function()
          return require('codecompanion.adapters').extend('cursor_cli', {
            defaults = { model = 'Auto' },
          })
        end,
        claude_code = function()
          return require('codecompanion.adapters').extend('claude_code', {
            defaults = { model = 'claude-sonnet-4.6' },
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = vim.env.ANTHROPIC_API_KEY,
            },
          })
        end,
        opencode = function()
          return require('codecompanion.adapters').extend('opencode', {
            commands = { default = { 'opencode', 'acp' } },
          })
        end,
      },
    },
    interactions = interactions,
  },
}
