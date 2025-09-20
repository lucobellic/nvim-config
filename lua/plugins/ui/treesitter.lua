return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    {
      'HiPhish/rainbow-delimiters.nvim',
      config = function()
        vim.g.rainbow_delimiters = {
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
    },
  },
}
