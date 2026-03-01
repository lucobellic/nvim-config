---@type CodeCompanion.Interactions
local interactions = vim.env.INSIDE_DOCKER
    and {
      cmd = { adapter = 'cursor', model = 'auto' },
      chat = { adapter = 'cursor', model = 'auto' },
      inline = { adapter = 'cursor', model = 'auto' },
    }
  or {
    cmd = { adapter = 'copilot', model = 'gpt-5-mini' },
    chat = { adapter = { name = 'copilot', model = 'claude-sonnet-4.6' } },
    inline = { adapter = { name = 'copilot', model = 'gpt-5-mini' } },
  }

return {
  'olimorris/codecompanion.nvim',
  opts = {
    ---@type CodeCompanion.Adapters
    adapters = {
      gitlab_duo = function() return require('plugins.codecompanion.adapters.gitlab-duo') end,
      copilot = function()
        return require('codecompanion.adapters').extend('copilot', {
          schema = { model = { default = 'gpt-5-mini' } },
        })
      end,
      acp = {
        opencode = function()
          return require('codecompanion.adapters').extend('claude_code', {
            name = 'opencode',
            formatted_name = 'OpenCode',
            commands = { default = { 'opencode', 'acp' } },
          })
        end,
        cursor = function()
          return require('codecompanion.adapters').extend('claude_code', {
            defaults = { model = 'auto' },
            name = 'cursor',
            formatted_name = 'Cursor',
            commands = { default = { 'cursor-agent', 'acp' } },
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
      },
    },
    interactions = interactions,
  },
}
