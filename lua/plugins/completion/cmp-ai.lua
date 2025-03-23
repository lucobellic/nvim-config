return {
  'tzachar/cmp-ai',
  enabled = false,
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    max_lines = 1000,
    provider = 'OpenAI',
    provider_options = {
      model = 'gpt-4',
    },
    notify = false,
    notify_callback = function(msg) vim.notify(msg) end,
    run_on_every_keystroke = false,
    ignored_file_types = {
      -- default is not to ignore
      -- uncomment to ignore in lua:
      -- lua = true
    },
  },
  config = function(_, opts)
    local cmp_ai = require('cmp_ai.config')
    cmp_ai:setup(opts)
  end,
}
