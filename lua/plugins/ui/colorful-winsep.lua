return {
  'nvim-zh/colorful-winsep.nvim',
  event = { 'WinEnter' },
  opts = {
    -- highlight for Window separator
    hi = {
      link = 'FloatBorder',
    },
    -- This plugin will not be activated for filetype in the following table.
    no_exec_files = {
      'packer',
      'TelescopePrompt',
      'mason',
      'NvimTree',
    },
    -- Symbols for separator lines, the order: horizontal, vertical, top left, top right, bottom left, bottom right.
    -- symbols = { '─', '│', '┌', '┐', '└', '┘' },
    symbols = { '─', '│', '╭', '╮', '╰', '╯' },
    -- Smooth moving switch
    smooth = false,
    zindex = 20,
    anchor = {
      left = { height = 1, x = -1, y = -1 },
      right = { height = 1, x = -1, y = 0 },
      up = { width = 0, x = -1, y = 0 },
      bottom = { width = 0, x = 1, y = 0 },
    },
  },
}
