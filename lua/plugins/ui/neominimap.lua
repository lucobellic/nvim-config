---@module 'neominimap'

return {
  'Isrothy/neominimap.nvim',
  version = 'v3.*.*',
  enabled = true,
  lazy = false,
  keys = {
    {'<leader>uM', '<cmd>Neominimap toggle<CR>', desc = 'Toggle minimap'},
  },
  init = function()
    vim.g.neominimap = {
      auto_enable = false,
      layout = 'split',
      float = {
        window_border = 'none',
      },
      diagnostic = {
        ---@type Neominimap.Handler.Annotation.Mode
        mode = 'sign',
      },
    }
  end,
}
