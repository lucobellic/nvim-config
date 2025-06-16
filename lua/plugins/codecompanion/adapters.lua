return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      agent = { adapter = { name = 'copilot', model = 'claude-sonnet-4' } },
      chat = { adapter = { name = 'copilot', model = 'claude-sonnet-4' } },
      inline = { adapter = { name = 'copilot', model = 'claude-sonnet-4' } },
    },
    adapters = {
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
