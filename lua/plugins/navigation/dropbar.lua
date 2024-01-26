return {
  {
    'Bekaboo/dropbar.nvim',
    event = 'BufEnter',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    keys = {
      {
        '<c-a>',
        function() require('dropbar.api').pick() end,
        desc = 'Pick Dropbar Item',
      },
    },
    opts = {
      icons = {
        kinds = {
          symbols = {
            File = ' ',
            Folder = '  ',
          },
        },
        ui = {
          bar = {
            separator = '   ',
            extends = '',
          },
          menu = {
            separator = ' ',
            indicator = '',
          },
        },
      },
      bar = {
        pick = {
          pivots = 'asdfghjkl;qwertyuiopzxcvbnm',
        },
      },
      menu = {
        preview = false, -- When on, preview the symbol under the cursor on CursorMoved
        scrollbar = {
          enable = true,
          background = false, -- When false, only the scrollbar thumb is shown.
        },
      },
    },
  },
}
