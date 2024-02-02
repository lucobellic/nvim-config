return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>a'] = { name = 'edgy-group' },
        ['<leader>at'] = { name = 'neotest' },
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
        '<leader>;',
        function()
          require('edgy-group.stl.statusline').pick(function() require('lualine').refresh() end)
        end,
        desc = 'Edgy Group Pick',
      },
      {
        '<c-;>',
        function()
          require('edgy-group.stl.statusline').pick(function() require('lualine').refresh() end)
        end,
        desc = 'Edgy Group Pick',
      },
    },
    opts = {
      groups = {
        left = {
          { icon = '', titles = { 'Neo-Tree Filesystem' }, pick_key = 'e' },
        },
        right = {
          { icon = '', titles = { 'outline', 'overseer' }, pick_key = 'o' },
          { icon = '󰙨', titles = { 'neotest-summary' }, pick_key = 's' },
          { icon = '', titles = { 'chatgpt' }, pick_key = 'g' },
        },
        bottom = {
          { icon = '', titles = { 'toggleterm' }, pick_key = 'p' },
          { icon = '', titles = { 'trouble' }, pick_key = 'x' },
          { icon = '󰙨', titles = { 'neotest-panel' }, pick_key = 't' },
        },
      },
      statusline = {
        clickable = true,
        colored = true,
        colors = {
          active = 'Identifier',
          inactive = 'Directory',
          pick_active = 'FlashMatch',
          pick_inactive = 'FlashLabel',
        },
      },
    },
    dev = true,
  },
}
