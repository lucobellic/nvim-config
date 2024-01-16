return {
  'lucobellic/edgy-group.nvim',
  dependencies = { 'folke/edgy.nvim' },
  event = 'VeryLazy',
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
    {
      '<leader>ek',
      function() require('edgy-group').open_group('bottom', 1) end,
      desc = 'Edgy Group Next Bottom',
      repeatable = true,
    },
    {
      '<leader>ej',
      function() require('edgy-group').open_group('bottom', -1) end,
      desc = 'Edgy Group Prev Bottom',
      repeatable = true,
    },
  },
  opts = {
    hide = true,
    groups = {
      { icon = '', pos = 'right', titles = { 'outline' } },
      { icon = '', pos = 'right', titles = { 'overseer' } },
      { icon = '', pos = 'bottom', titles = { 'toggleterm' } },
      { icon = '', pos = 'bottom', titles = { 'trouble' } },
      { icon = '', pos = 'bottom', titles = { 'spectre' } },
      -- { icon = '', pos = 'left', titles = { 'Neo-Tree', 'Neo-Tree Buffers' } },
      -- { icon = '', pos = 'left', titles = { 'Neo-Tree Git' } },
      -- { icon = '', pos = 'left', titles = { 'Outline' } },
    },
  },
  dev = true,
}
