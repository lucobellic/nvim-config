return {
  'stevearc/quicker.nvim',
  ft = { 'qf', 'loclist' },
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {
    keys = {
      {
        'L',
        function() require('quicker').expand({ before = 2, after = 2, add_to_existing = true }) end,
        desc = 'Expand quickfix context',
      },
      {
        'H',
        function() require('quicker').collapse() end,
        desc = 'Collapse quickfix context',
      },
    },
  },
}
