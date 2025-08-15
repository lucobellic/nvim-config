return {
  'nvim-treesitter/nvim-treesitter',
  enabled = true,
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
  keys = (function()
    local keys = {}

    -- Helper function to create key mappings
    local function add_movement_key(key, node_type, direction, desc_prefix)
      local func_name = direction == 'next' and 'goto_next_start' or 'goto_previous_start'
      local desc_direction = direction == 'next' and 'Next' or 'Previous'

      table.insert(keys, {
        key,
        function() require('nvim-treesitter.textobjects.move')[func_name](node_type, 'textobjects') end,
        mode = { 'n', 'v' },
        repeatable = true,
        desc = string.format('Go To %s %s', desc_direction, desc_prefix),
      })
    end

    -- Add function navigation keys
    add_movement_key('>f', '@function.outer', 'next', 'Function')
    add_movement_key('>F', '@function.outer', 'next', 'Function Outer')
    add_movement_key('<f', '@function.outer', 'previous', 'Function')
    add_movement_key('<F', '@function.outer', 'previous', 'Function Outer')

    -- Add class navigation keys
    add_movement_key('>c', '@class.outer', 'next', 'Class')
    add_movement_key('>C', '@class.outer', 'next', 'Class')
    add_movement_key('<c', '@class.outer', 'previous', 'Class')
    add_movement_key('<C', '@class.outer', 'previous', 'Class')

    return keys
  end)(),
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
