require('notify').setup({
  background_colour = "Normal",
  fps = 30,
  icons = {
    DEBUG = "",
    ERROR = "",
    INFO = "",
    TRACE = "✎",
    WARN = ""
  },
  level = 2,
  minimum_width = 30,
  render = "simple",
  stages = "fade_in_slide_out",
  timeout = 2000,
  top_down = false
})

vim.notify = require("notify")
