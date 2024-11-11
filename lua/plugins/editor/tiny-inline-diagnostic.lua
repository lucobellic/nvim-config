return {
  'rachartier/tiny-inline-diagnostic.nvim',
  enabled = false, -- Slow due to CursorMoved event without throttle
  event = 'LspAttach',
  keys = {
    {
      '<leader>udb',
      function() require('tiny-inline-diagnostic').toggle() end,
      desc = 'Toggle Diagnostic Tiny Inline',
    },
  },
  opts = {
    signs = {
      left = '',
      right = '',
      diag = ' ',
      arrow = '',
      up_arrow = ' │',
      vertical = ' │',
      vertical_end = ' └',
    },
    blend = {
      factor = 0.2,
    },
    hi = {
      error = 'Error',
      warn = 'WarningMsg',
    },
  },
  config = function(_, opts)
    require('tiny-inline-diagnostic').setup(opts)
    require('tiny-inline-diagnostic').disable()
  end,
}
