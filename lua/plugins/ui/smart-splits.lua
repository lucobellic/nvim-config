return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  keys = {

    { '<C-left>',  function() require('smart-splits').resize_left() end,       desc = 'Resize left' },
    { '<C-down>',  function() require('smart-splits').resize_down() end,       desc = 'Resize down' },
    { '<C-up>',    function() require('smart-splits').resize_up() end,         desc = 'Resize up' },
    { '<C-right>', function() require('smart-splits').resize_right() end,      desc = 'Resize right' },
    { '<S-left>',  function() require('smart-splits').move_cursor_left() end,  desc = 'Move cursor left' },
    { '<S-down>',  function() require('smart-splits').move_cursor_down() end,  desc = 'Move cursor down' },
    { '<S-up>',    function() require('smart-splits').move_cursor_up() end,    desc = 'Move cursor up' },
    { '<S-right>', function() require('smart-splits').move_cursor_right() end, desc = 'Move cursor right' },
    { '<A-H>',     function() require('smart-splits').swap_buf_left() end,     desc = 'Swap buffer left' },
    { '<A-J>',     function() require('smart-splits').swap_buf_down() end,     desc = 'Swap buffer down' },
    { '<A-K>',     function() require('smart-splits').swap_buf_up() end,       desc = 'Swap buffer up' },
    { '<A-L>',     function() require('smart-splits').swap_buf_right() end,    desc = 'Swap buffer right' },
  },
  config = function()
    require('smart-splits').setup({
      -- Ignored filetypes (only while resizing)
      ignored_filetypes = {
        'nofile',
        'quickfix',
        'prompt',
      },
      -- Ignored buffer types (only while resizing)
      ignored_buftypes = { 'NvimTree', 'neo-tree' },
      smart_splits = {},
    })
  end
}
