return {
  url = 'git@github.com:lucobellic/edgy-group.nvim.git',
  dependencies = { 'folke/edgy.nvim' },
  keys = {
    {
      '<leader>el',
      function() require('edgy-group').open_group('right', 1) end,
      desc = 'Edgy Group Next Right',
      repeatable = true,
    },
    {
      '<leader>eh',
      function() require('edgy-group').open_group('right', -1) end,
      desc = 'Edgy Group Prev Right',
      repeatable = true,
    },
  },
  opts = {
    hide = true,
    groups = {
      { icon = '', pos = 'right', titles = { 'outline' } },
      { icon = '', pos = 'right', titles = { 'overseer' } },
    },
  },
  dev = true,
}
