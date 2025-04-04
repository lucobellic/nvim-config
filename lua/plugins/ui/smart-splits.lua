return {
  'lucobellic/smart-splits.nvim',
  vscode = false,
  lazy = false,
  branch = 'feature/edgy-resize',
  keys = {
    -- Navigation
    { '<C-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move cursor left', mode = 'n' },
    { '<C-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move cursor down', mode = 'n' },
    { '<C-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move cursor up', mode = 'n' },
    { '<C-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move cursor right', mode = 'n' },
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
