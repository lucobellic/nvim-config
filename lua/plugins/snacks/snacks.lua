return {
  'folke/snacks.nvim',
  keys = {
    { '<leader>..', function() require('snacks').scratch() end, desc = 'Scratch Toggle Buffer' },
    { '<leader>f.', function() require('snacks').scratch.select() end, desc = 'Scratch Select Buffer' },
    { '<leader>fe', false },
  },
  opts = function()
    local snacks = require('snacks')
    snacks.toggle.profiler():map('<leader>pp')
    snacks.toggle.profiler_highlights():map('<leader>ph')

    ---@type snacks.plugins.Config
    return {
      scratch = { backdrop = false },
      words = { enabled = false },
      terminal = {
        stack = true,
        position = 'bottom',
        row = 10,
        win = {
          wo = { winbar = '' },
          keys = {
            term_normal = false,
            gf = {
              'gf',
              function() require('util.util').open_file(false) end,
              mode = { 'n', 'x' },
              desc = 'Go to file',
            },
            gF = {
              'gF',
              function() require('util.util').open_file(true) end,
              mode = { 'n', 'x' },
              desc = 'Go to file (with line)',
            },
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
