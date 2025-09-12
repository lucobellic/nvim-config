return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      agent = { adapter = { name = 'copilot', model = 'gpt-5-mini' } },
      chat = { adapter = { name = 'copilot', model = 'gpt-5-mini' } },
      inline = { adapter = { name = 'copilot', model = 'gpt-5-mini' } },
    },
  },
}
