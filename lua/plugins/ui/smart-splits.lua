return {
  'mrjones2014/smart-splits.nvim',
  event = 'VeryLazy',
  opts = {
    -- Ignored filetypes (only while resizing)
    ignored_filetypes = {
      'nofile',
      'quickfix',
      'prompt',
    },
    -- Ignored buffer types (only while resizing)
    ignored_buftypes = { 'NvimTree', 'neo-tree' },
    smart_splits = {},
  },
}
