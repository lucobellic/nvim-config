return {
  'nvim-tree/nvim-tree.lua',
  enabled = false,
  event = 'BufEnter',
  opts = {
    disable_netrw = true,
    hijack_netrw = true,
    sort = {
      sorter = 'case_sensitive',
    },
    view = {
      width = 40,
      side = 'left',
    },
    renderer = {
      root_folder_label = ':t:r',
      group_empty = true,
      indent_markers = {
        enable = false,
        inline_arrows = true,
      },
      icons = {
        web_devicons = {
          file = {
            enable = true,
            color = true,
          },
          folder = {
            enable = false,
            color = true,
          },
        },
        git_placement = 'signcolumn',
        glyphs = {
          default = '',
          symlink = '',
          bookmark = '󰆤',
          modified = '●',
          folder = {
            arrow_closed = '',
            arrow_open = '',
            default = '',
            open = '',
            empty = '',
            empty_open = '',
            symlink = '',
            symlink_open = '',
          },
          git = {
            unstaged = '',
            staged = '',
            unmerged = '',
            renamed = '➜',
            untracked = '',
            deleted = '',
            ignored = '',
          },
        },
      },
    },
    filters = {
      dotfiles = false,
    },
  },
}
