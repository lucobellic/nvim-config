require('notify').setup({
  background_colour = "NotifyBackground",
  fps = 30,
  level = 2,
  minimum_width = 50,
  max_width = 100,
  max_height = 5,
  render = 'compact', -- 'default', 'minimal', 'simple', 'compact'
  stages = 'slide',   -- 'fade_in_slide_out', 'fade', 'slide', 'static'
  timeout = 1000,
  top_down = false
})
