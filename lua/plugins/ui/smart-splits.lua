return {
  'mrjones2014/smart-splits.nvim',
  vscode = false,
  lazy = false,
  branch = 'master',
  keys = {
    { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move cursor left', mode = 'n' },
    { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move cursor down', mode = 'n' },
    { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move cursor up', mode = 'n' },
    { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move cursor right', mode = 'n' },
    { '<C-left>', function() require('smart-splits').resize_left() end, desc = 'Resize left', mode = 'n' },
    { '<C-down>', function() require('smart-splits').resize_down() end, desc = 'Resize down', mode = 'n' },
    { '<C-up>', function() require('smart-splits').resize_up() end, desc = 'Resize up', mode = 'n' },
    { '<C-right>', function() require('smart-splits').resize_right() end, desc = 'Resize right', mode = 'n' },
  },
  opts = {
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = {
      'NvimTree',
      'neo-tree',
      'OverseerList',
      'Outline',
      'neominimap',
    },
    -- Ignored buffer types (only while resizing)
    ignored_buftypes = {
      'nofile',
      'quickfix',
      'prompt',
    },
  },
}
