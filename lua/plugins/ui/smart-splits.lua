return {
  'lucobellic/smart-splits.nvim',
  branch = 'feature/edgy-resize',
  keys = {
    -- Navigation
    { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move cursor left' },
    { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move cursor down' },
    { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move cursor up' },
    { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move cursor right' },
  },
  opts = {
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = {
      'NvimTree',
      'neo-tree',
      'OverseerList',
      'Outline',
    },
    -- Ignored buffer types (only while resizing)
    ignored_buftypes = {
      'nofile',
      'quickfix',
      'prompt',
    },
  },
}
