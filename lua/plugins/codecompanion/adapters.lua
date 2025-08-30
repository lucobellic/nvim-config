return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      agent = { adapter = { name = 'copilot', model = 'gpt-4.1' } },
      chat = { adapter = { name = 'copilot', model = 'gpt-4.1' } },
      inline = { adapter = { name = 'copilot', model = 'gpt-4.1' } },
    },
  },
}
