return {
  'stevearc/dressing.nvim',
  opts = {
    input = {
      border = vim.g.border.style,
    },
    select = {
      builtin = {
        border = vim.g.border.style,
      },
      telescope = {
        borderchars = vim.g.border.borderchars,
      },
      format_item_override = {
        ['legendary.nvim'] = function(items)
          local values = require('legendary.ui.format').default_format(items)
          return string.format('%-20s • %-20s', values[2], values[3])
        end,
      },
    },
  },
}
