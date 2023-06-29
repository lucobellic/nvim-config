return {
  'rcarriga/nvim-notify',
  opts = {
    background_colour = "NotifyBackground",
    fps = 30,
    level = 2,
    minimum_width = 50,
    max_width = 100,
    max_height = 5,
    render = 'compact', -- 'default', 'minimal', 'simple', 'compact'
    stages = require('plugins.popup.notify.limited_slide'),
    timeout = 1000,
    top_down = false
  }
}
