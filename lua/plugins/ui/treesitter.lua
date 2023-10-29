return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    {
      'HiPhish/rainbow-delimiters.nvim',
      config = function(_, opts)
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
            'TSRainbowYellow',
            'TSRainbowViolet',
            'TSRainbowBlue',
            'TSRainbowOrange',
            'TSRainbowGreen',
            'TSRainbowViolet',
            'TSRainbowCyan',
            'TSRainbowRed',
          },
        }
      end,
    },
  },
  opts = {
    ensure_installed = {
      'cmake',
      'python',
      'yaml',
      'json',
      'vim',
      'markdown',
      'markdown_inline',
    },
    highlight = {
      enable = true,
      custom_captures = {
        -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
        -- ["foo.bar"] = "Constant",
      },
    },
    textobjects = {
      select = {
        enabled = true,
      },
      move = {
        enable = true,
        goto_next_start = {
          ['>f'] = '@function.outer',
          ['>F'] = '@function.outer',
        },
        goto_previous_start = {
          ['<f'] = '@function.outer',
          ['<F'] = '@function.outer',
        },
      },
    },
  },
}
