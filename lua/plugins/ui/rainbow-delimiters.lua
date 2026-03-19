return {
  'HiPhish/rainbow-delimiters.nvim',
  event = 'VeryLazy',
  opts = function()
    return {
      strategy = {
        [''] = require('rainbow-delimiters').strategy['global'],
        vim = require('rainbow-delimiters').strategy['local'],
      },
      query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
      },
      highlight = {
        'RainbowYellow',
        'RainbowLightGreen',
        'RainbowViolet',
        'RainbowBlue',
        'RainbowLightGreen',
        'RainbowCyan',
        'RainbowViolet',
      },
    }
  end,
  config = function(_, opts) require('rainbow-delimiters.setup').setup(opts) end,
}
