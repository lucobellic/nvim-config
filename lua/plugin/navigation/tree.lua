require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  disable_netrw = true,
  hijack_netrw = true,
  sync_root_with_cwd = true,
  view = {
    adaptive_size = false,
    side = 'left',
    width = 40,
    hide_root_folder = false,
    mappings = {
      custom_only = false,
      list = {
        { key = 'u', action = 'dir_up' },
        { key = 'l', action = 'edit', action_cb = edit_or_open },
        { key = 'L', action = 'vsplit_preview', action_cb = vsplit_preview },
        { key = 'h', action = 'close_node' },
        { key = '<CR>', action = 'cd', action_cb = cd },
        { key = { 'E', 'zr', 'zR' }, action = 'expand_all', action_cb = expand_all },
        { key = { 'H', 'zm', 'zM' }, action = 'collapse_all', action_cb = collapse_all },
      },
    },
  },
  git = {
    enable = false -- disable for performances reasons
  },
  actions = {
    open_file = {
      quit_on_open = false
    }
  },
  renderer = {
    root_folder_label = ":t:r",
    group_empty = true,
    indent_markers = {
      enable = false,
      inline_arrows = true,
    },
    icons = {
      webdev_colors = true,
      show = {
        folder_arrow = false,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
  diagnostics = {
    enable = true
  },
  update_focused_file = {
    enable = true
  }
})


vim.keymap.set('n', '<leader>el', ':NvimTreeFindFileToggle<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<C-b>', ':NvimTreeFindFileToggle<cr>', { silent = true, noremap = true })
