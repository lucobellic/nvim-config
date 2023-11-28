return {
  'rcarriga/nvim-notify',
  enabled = not vim.g.started_by_firenvim,
  opts = {
    background_colour = 'NotifyBackground',
    fps = 30,
    level = 2,
    minimum_width = 60,
    max_width = 60,
    max_height = 5,
    render = 'wrapped-compact', -- 'default', 'minimal', 'simple', 'compact', 'wrapped-compact'
    stages = require('util.notify.limited_slide'),
    timeout = 1000,
    top_down = false,
  },
}
