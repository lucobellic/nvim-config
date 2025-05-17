return {
  'folke/edgy.nvim',
  opts = {
    right = {
      {
        title = 'neotest-summary',
        ft = 'neotest-summary',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        open = 'Neotest summary',
        size = { width = 0.20 },
      },
    },
    bottom = {
      {
        title = 'neotest-panel',
        ft = 'neotest-output-panel',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        size = { height = 0.25 },
        open = 'Neotest output-panel',
      },
    },
  },
}
