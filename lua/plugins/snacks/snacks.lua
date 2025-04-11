return {
  'folke/snacks.nvim',
  keys = {
    { '<leader>..', function() require('snacks').scratch() end, desc = 'Scratch Toggle Buffer' },
    { '<leader>f.', function() require('snacks').scratch.select() end, desc = 'Scratch Select Buffer' },
    { '<leader>ps', function() require('snacks').profiler.scratch() end, desc = 'Scratch Profiler Buffer' },
    { '<leader>fe', false },
  },
  opts = function()
    local snacks = require('snacks')
    snacks.toggle.profiler():map('<leader>pp')
    snacks.toggle.profiler_highlights():map('<leader>ph')
    return {
      words = { enabled = false },
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
