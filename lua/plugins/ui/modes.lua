return {
  dir = vim.fn.stdpath('config') .. '/local/modes',
  name = 'modes',
  event = { 'ModeChanged', 'ColorScheme' },
  ---@type ModesConfig
  opts = {
    highlights = {
      insert = {
        CursorLine = { bg = '#1B3320' },
        CursorLineNr = { bg = '#1B3320' },
        CursorLineFold = { bg = '#1B3320' },
      },
      visual = {
        CursorLine = { bg = '#1b3a5a' },
        CursorLineNr = { bg = '#1b3a5a' },
        CursorLineFold = { bg = '#1b3a5a' },
      },
    },
  },
}
