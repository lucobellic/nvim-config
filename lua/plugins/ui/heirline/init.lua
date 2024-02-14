return {
  'rebelot/heirline.nvim',
  enabled = true,
  event = 'UIEnter',
  dependencies = {
    'stevearc/overseer.nvim',
  },
  config = function(_, default_opts)
    local heirline_opts = {
      statusline = require('plugins.ui.heirline.statusline'),
      opts = {
        colors = require('plugins.ui.heirline.colors').colors,
      },
    }
    local opts = vim.tbl_deep_extend('force', heirline_opts, default_opts) or {}
    require('heirline').setup(opts)
  end,
}
