return {
  'folke/snacks.nvim',
  keys = {
    { '<c-z>', function() require('snacks.zen').zen() end, desc = 'Toggle Zen Mode' },
    {
      '<leader>zd',
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
    styles = {
      fullzen = {
        enter = true,
        fixbuf = false,
        minimal = false,
        width = 120,
        height = 0,
        backdrop = { transparent = false, blend = 80 },
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
