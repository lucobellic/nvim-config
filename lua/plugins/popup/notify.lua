return {
  'rcarriga/nvim-notify',
  enabled = not vim.g.started_by_firenvim,
  opts = {
    background_colour = 'NotifyBackground',
    fps = 30,
    level = 2,
    minimum_width = 80,
    max_width = 80,
    max_height = 8,
    render = 'wrapped-compact', -- 'default', 'minimal', 'simple', 'compact', 'wrapped-compact'
    timeout = 1000,
    top_down = false,
    icons = {
      DEBUG = '',
      ERROR = '',
      INFO = '',
      TRACE = '',
      WARN = '',
    },
  },
  config = function(_, opts)
    opts.stages = require('util.notify.limited_slide')
    require('notify').setup(opts)
  end,
}
