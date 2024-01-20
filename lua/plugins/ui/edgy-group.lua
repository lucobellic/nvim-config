return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>eg'] = { name = 'edgy-group' },
      },
    },
  },
  {
    'lucobellic/edgy-group.nvim',
    dependencies = { 'folke/edgy.nvim' },
    event = 'VeryLazy',
    keys = {
      {
        '<leader>el',
        function() require('edgy-group').open_group_offset('right', 1) end,
        desc = 'Edgy Group Next Right',
        repeatable = true,
      },
      {
        '<leader>eh',
        function() require('edgy-group').open_group_offset('right', -1) end,
        desc = 'Edgy Group Prev Right',
        repeatable = true,
      },
      {
        '<leader>ek',
        function() require('edgy-group').open_group_offset('bottom', 1) end,
        desc = 'Edgy Group Next Bottom',
        repeatable = true,
      },
      {
        '<leader>ej',
        function() require('edgy-group').open_group_offset('bottom', -1) end,
        desc = 'Edgy Group Prev Bottom',
        repeatable = true,
      },
      {
        '<leader>egs',
        '<cmd>EdgyGroupSelect<cr>',
        desc = 'Edgy Group Select',
      },
    },
    opts = {
      groups = {
        right = {
          { icon = '', titles = { 'outline' } },
          { icon = '', titles = { 'overseer' } },
        },
        bottom = {
          { icon = '', titles = { 'toggleterm' } },
          { icon = '', titles = { 'trouble' } },
          { icon = '', titles = { 'spectre' } },
        },
        -- { icon = '', pos = 'left', titles = { 'Neo-Tree', 'Neo-Tree Buffers' } },
        -- { icon = '', pos = 'left', titles = { 'Neo-Tree Git' } },
        -- { icon = '', pos = 'left', titles = { 'Outline' } },
      },
      statusline = {
        clickable = true,
        colored = true,
        colors = {
          active = 'Identifier',
          inactive = 'Directory',
        },
      },
    },
    dev = true,
  },
}
