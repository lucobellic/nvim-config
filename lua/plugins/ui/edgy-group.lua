return {
  {
    'lucobellic/edgy-group.nvim',
    dependencies = { 'folke/edgy.nvim' },
    event = 'VeryLazy',
    keys = {
      {
        '<leader>;',
        function() require('edgy-group.stl').pick() end,
        desc = 'Edgy Group Pick',
      },
      {
        '<c-;>',
        function() require('edgy-group.stl').pick() end,
        desc = 'Edgy Group Pick',
      },
    },
    opts = {
      groups = {
        right = {
          { icon = '', titles = { 'outline' }, pick_key = 'o' },
          { icon = '󰙨', titles = { 'neotest-summary' }, pick_key = 't' },
          { icon = '', titles = { 'copilot-chat' }, pick_key = 'c' },
          {
            icon = '',
            titles = {
              'OGPT Popup',
              'OGPT Parameters',
              'OGPT Template',
              'OGPT Sessions',
              'OGPT System Input',
              'OGPT',
              'OGPT Selection',
              'OGPT Instruction',
              'OGPT Chat',
            },
            pick_key = 'g',
          },
        },
        bottom = {
          { icon = '', titles = { 'toggleterm', 'toggleterm-tasks', 'overseer' }, pick_key = 'p' },
          { icon = '', titles = { 'trouble-diagnostics', 'trouble-qflist' }, pick_key = 'x' },
          { icon = '', titles = { 'trouble-telescope' }, pick_key = 's' },
          { icon = '', titles = { 'trouble-lsp-references', 'trouble-lsp-definitions' }, pick_key = 'r' },
          { icon = '', titles = { 'noice' }, pick_key = 'n' },
          { icon = '󰙨', titles = { 'neotest-panel' }, pick_key = 't' },
        },
      },
      statusline = {
        clickable = true,
        colored = true,
        colors = {
          active = 'Identifier',
          inactive = 'Directory',
          pick_active = 'FlashLabel',
          pick_inactive = 'FlashLabel',
        },
        pick_key_pose = 'right_separator',
      },
    },
  },
}
