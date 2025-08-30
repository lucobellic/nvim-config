return {
  'nvim-treesitter/nvim-treesitter',
  enabled = true,
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
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
    auto_install = true,
    highlight = { enable = true },
    textobjects = {
      select = { enabled = true },
      move = {
        enable = true,
        goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
        goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
        goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
        goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
      },
    },
  },
}
