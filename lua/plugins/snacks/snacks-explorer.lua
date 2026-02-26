return {
  'snacks.nvim',
  ---@type snacks.Config
  keys = {
    {
      '<leader>es',
      function() Snacks.explorer.reveal() end,
      desc = 'Snacks Explorer',
    },
  },
  opts = {
    picker = {
      sources = {
        explorer = {
          icons = {
            diagnostics = {
              Hint = '  ',
              Info = '  ',
              Warn = ' ',
              Error = ' ',
            },
            files = {
              dir = ' ',
              dir_open = ' ',
              file = ' ',
            },
            git = {
              commit = '󰜘 ',
              staged = '',
              added = '',
              deleted = '',
              ignored = ' ',
              modified = '',
              renamed = '',
              unmerged = ' ',
              untracked = '',
            },
            tree = {
              last = '╰╴',
              middle = '│ ',
              vertical = '│ ',
            },
          },
        },
      },
    },
  },
}
