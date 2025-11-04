return {
  'olimorris/codecompanion.nvim',
  opts = {
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
            commands = {
              default = { 'opencode', 'acp' },
            },
          })
        end,
      },
    },
    ---@type CodeCompanion.Strategies
    strategies = {
      cmd = { adapter = 'copilot', model = 'gpt-5-mini' },
      chat = { adapter = { name = 'copilot', model = 'claude-sonnet-4.5' } },
      inline = { adapter = { name = 'copilot', model = 'gpt-5-mini' } },
    },
  },
}
