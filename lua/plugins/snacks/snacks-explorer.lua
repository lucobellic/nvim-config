return {
  'snacks.nvim',
  ---@type snacks.Config
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
