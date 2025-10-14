return {
  'snacks.nvim',
  keys = {
    { '<c-z>', function() require('snacks.zen').zen() end, desc = 'Toggle Zen Mode' },
    { '<leader>zz', function() require('snacks.zen').zen() end, desc = 'Toggle Zen Mode' },
    { '<leader>zm', function() require('snacks.zen').zoom() end, desc = 'Toggle Zoom Mode' },
    {
      '<leader>uD',
      function()
        local dim = require('snacks.dim')
        if dim.enabled then
          dim.disable()
        else
          dim.enable()
        end
      end,
      desc = 'Toggle Dim Mode',
    },
  },
  opts = {
    spec = { { '<leader>z', group = 'zen' } },
    styles = {
      fullzen = {
        enter = true,
        fixbuf = false,
        minimal = false,
        width = 120,
        height = 0,
        backdrop = vim.g.neovide and { transparent = true, blend = 0 } or { transparent = false, blend = 99 },
        keys = { q = false },
        zindex = 40,
        w = { snacks_main = true },
      },
    },
    zen = {
      enabled = true,
      win = { style = 'fullzen' },
    },
  },
}
