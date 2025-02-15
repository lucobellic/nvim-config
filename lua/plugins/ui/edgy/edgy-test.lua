return {
  'folke/edgy.nvim',
  opts = {
    right = {
      {
        title = 'neotest-summary',
        ft = 'neotest-summary',
        open = 'Neotest summary',
        size = { width = 0.20 },
      },
    },
    bottom = {
      {
        title = 'neotest-panel',
        ft = 'neotest-output-panel',
        size = { height = 0.25 },
        open = 'Neotest output-panel',
      },
    },
  },
}
