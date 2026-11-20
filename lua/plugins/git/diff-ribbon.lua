return {
  dir = vim.fn.stdpath('config') .. '/local/diff-ribbon',
  name = 'diff-ribbon',
  lazy = true,
  enabled = vim.g.diff_ribbon == true,
  keys = {
    {
      '<leader>uR',
      function()
        local is_enabled = require('diff-ribbon').toggle()
        local text = (is_enabled and 'Enabled' or 'Disabled') .. ' diff ribbon'
        local level = is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(text, level, { title = 'Options' })
      end,
      desc = 'Toggle Diff Ribbon',
    },
  },
  ---@type DiffRibbon.Options
  opts = {
    width = 5,
    -- Kitty cell size in pixels, used in the container where the terminal cannot report it.
    cell_size = { width = 10, height = 22 },
  },
}
