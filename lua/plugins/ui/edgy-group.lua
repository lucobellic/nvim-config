return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>.'] = { name = 'edgy-group' },
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
        '<leader>..',
        '<cmd>EdgyGroupSelect<cr>',
        desc = 'Edgy Group Select',
      },
      {
        '<leader>.o',
        function() require('edgy-group').open_group_index('right', 1) end,
        desc = 'Open Outline And Oversser',
      },
      {
        '<leader>.g',
        function() require('edgy-group').open_group_index('right', 2) end,
        desc = 'Open ChatGPT',
      },
      {
        '<leader>.p',
        function() require('edgy-group').open_group_index('bottom', 1) end,
        desc = 'Open Toggleterm',
      },
      {
        '<leader>.t',
        function() require('edgy-group').open_group_index('bottom', 2) end,
        desc = 'Open Trouble',
      },
      {
        '<leader>.s',
        function() require('edgy-group').open_group_index('bottom', 3) end,
        desc = 'Open Spectre',
      },
    },
    opts = {
      groups = {
        right = {
          { icon = '', titles = { 'outline', 'overseer' } },
          { icon = '', titles = { 'chatgpt' } },
        },
        bottom = {
          { icon = '', titles = { 'toggleterm' } },
          { icon = '', titles = { 'trouble' } },
          { icon = '', titles = { 'spectre' } },
        },
        -- left = {
        --   { icon = '', titles = { 'Neo-Tree Filesystem', 'Neo-Tree Buffers' } },
        --   { icon = '', titles = { 'Neo-Tree Git' } },
        -- },
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
