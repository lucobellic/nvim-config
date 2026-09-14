return {
  'lucobellic/cursor-tab.nvim',
  dev = true,
  enabled = vim.g.suggestions == 'cursor-tab',
  lazy = false,
  cond = false,
  opts = {
    -- log_level = vim.log.levels.DEBUG,
    completion = {
      normal_mode = true,
    },
    sign = {
      text = '',
      priority = 10000,
    },
    backend = {
      filesync = true,
    },
  },
}
