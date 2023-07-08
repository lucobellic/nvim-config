return {
  'stevearc/dressing.nvim',
  opts = {
    select = {
      format_item_override = {
        ['legendary.nvim'] = function(items)
          local values = require('legendary.ui.format').default_format(items)
          return string.format("%-20s • %-20s", values[2], values[3])
        end
      }
    }
  }
}
