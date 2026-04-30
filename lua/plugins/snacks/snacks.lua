return {
  'folke/snacks.nvim',
  keys = {
    {
      '<leader>uP',
      function() Snacks.terminal.toggle(nil, { win = { position = 'bottom' } }) end,
      desc = 'Toggle Terminal',
    },
    {
      '<leader>up',
      function() Snacks.terminal.toggle(nil, { win = { position = 'bottom' } }) end,
      desc = 'Toggle Terminal',
    },
    { '<leader>..', function() require('snacks').scratch() end, desc = 'Scratch Toggle Buffer' },
    { '<leader>f.', function() require('snacks').scratch.select() end, desc = 'Scratch Select Buffer' },
    { '<leader>fe', false },
  },
  opts = function()
    local snacks = require('snacks')
    snacks.toggle.profiler():map('<leader>pp')
    snacks.toggle.profiler_highlights():map('<leader>ph')
    return {
      scratch = { backdrop = false },
      words = { enabled = false },
      terminal = {
        win = {
          wo = { winbar = '' },
          keys = {
            term_normal = false,
          },
        },
      },
      ---@type snacks.bigfile.Config
      bigfile = {
        enabled = true,
        notify = false,
      },
      notifier = {
        enabled = false,
        top_down = false,
        width = { min = 80, max = 80 },
        height = { min = 1, max = 8 },
        icons = {
          error = ' ',
          warn = ' ',
          info = ' ',
          debug = ' ',
          trace = ' ',
        },
      },
    }
  end,
}
