return {
  {
    'lucobellic/edgy-group.nvim',
    enabled = not vim.g.started_by_firenvim,
    dependencies = { 'folke/edgy.nvim' },
    event = 'VeryLazy',
    keys = {
      {
        '<leader>;',
        function()
          require('edgy-group.stl').pick(function() require('lualine').refresh() end)
        end,
        desc = 'Edgy Group Pick',
      },
      {
        '<c-;>',
        function()
          require('edgy-group.stl').pick(function() require('lualine').refresh() end)
        end,
        desc = 'Edgy Group Pick',
      },
    },
    opts = {
      groups = {
        right = {
          { icon = '', titles = { 'outline', 'overseer' }, pick_key = 'o' },
          { icon = '󰙨', titles = { 'neotest-summary' }, pick_key = 't' },
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
          pick_active = 'FlashLabel',
          pick_inactive = 'FlashLabel',
        },
        pick_key_pose = 'right_separator',
      },
    },
    dev = true,
  },
}
