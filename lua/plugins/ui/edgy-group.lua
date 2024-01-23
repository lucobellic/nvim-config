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
        '<leader>aa',
        '<cmd>EdgyGroupSelect<cr>',
        desc = 'Edgy Group Select',
      },
      {
        '<leader>ao',
        function() require('edgy-group').open_group_index('right', 1) end,
        desc = 'Open Outline And Overseer',
      },
      {
        '<leader>ats',
        function() require('edgy-group').open_group_index('right', 2) end,
        desc = 'Open NeoTest Summary',
      },
      {
        '<leader>ag',
        function() require('edgy-group').open_group_index('right', 3) end,
        desc = 'Open ChatGPT',
      },
      {
        '<leader>ap',
        function() require('edgy-group').open_group_index('bottom', 1) end,
        desc = 'Open Toggleterm',
      },
      {
        '<leader>ax',
        function() require('edgy-group').open_group_index('bottom', 2) end,
        desc = 'Open Trouble',
      },
      {
        '<leader>ato',
        function() require('edgy-group').open_group_index('bottom', 3) end,
        desc = 'Open Neotest Panel',
      },
    },
    opts = {
      groups = {
        right = {
          { icon = '', titles = { 'outline', 'overseer' } },
          { icon = '󰙨', titles = { 'neotest-summary' } },
          { icon = '', titles = { 'chatgpt' } },
        },
        bottom = {
          { icon = '', titles = { 'toggleterm' } },
          { icon = '', titles = { 'trouble' } },
          { icon = '󰙨', titles = { 'neotest-panel' } },
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
