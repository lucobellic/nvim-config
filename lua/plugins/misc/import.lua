return {
  'piersolenski/import.nvim',
  dependencies = {
    'folke/snacks.nvim',
  },
  keys = {
    {
      '<leader>si',
      function() require('import').pick() end,
      desc = 'Search Import',
    },
  },
  opts = {
    picker = 'snacks',
  },
}
