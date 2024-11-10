return {
  'folke/snacks.nvim',
  opts = {
    notifier = {
      top_down = false,
      width = { min = 60, max = 60 },
      height = { min = 1, max = 8 },
      icons = {
        error = ' ',
        warn = ' ',
        info = ' ',
        debug = ' ',
        trace = ' ',
      },
    },
  },
}
