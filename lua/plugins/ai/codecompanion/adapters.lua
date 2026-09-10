---@type CodeCompanion.Interactions
local interactions = vim.env.INSIDE_DOCKER
    and {
      cmd = { adapter = 'cursor_cli', model = 'Auto' },
      chat = { adapter = 'cursor_cli', model = 'Auto' },
      inline = { adapter = 'cursor_cli', model = 'Auto' },
    }
  or {
    cmd = { adapter = { name = 'cocodex', model = 'gpt-5.6-luna' } },
    chat = { adapter = { name = 'cocodex', model = 'gpt-5.6-luna' } },
    inline = { adapter = { name = 'cocodex', model = 'gpt-5.6-luna' } },
  }

return {
  'olimorris/codecompanion.nvim',
  opts = {
    ---@type CodeCompanion.Adapters
    adapters = {
      http = {
        cocodex = function()
          return require('codecompanion.adapters').extend(require('plugins.ai.codecompanion.adapters.http.codex'), {
            schema = {
              model = { default = 'gpt-5.6-luna' },
              reasoning_effort = { default = 'none' },
            },
          })
        end,
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
