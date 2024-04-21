return {
  'mrjones2014/smart-splits.nvim',
  lazy = false, -- Do not lazy load with wezterm
  keys = {
    -- Navigation
    { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move cursor left' },
    { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move cursor down' },
    { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move cursor up' },
    { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move cursor right' },
    --- Resize
    { '<C-Left>', function() require('smart-splits').resize_left() end, desc = 'Resize left' },
    { '<C-Down>', function() require('smart-splits').resize_down() end, desc = 'Resize down' },
    { '<C-Up>', function() require('smart-splits').resize_up() end, desc = 'Resize up' },
    { '<C-Right>', function() require('smart-splits').resize_right() end, desc = 'Resize right' },
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
