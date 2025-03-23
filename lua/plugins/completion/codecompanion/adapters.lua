return {
  copilot = function()
    return require('codecompanion.adapters').extend('copilot', {
      schema = { model = { default = 'claude-3.7-sonnet-thought' } },
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
}
