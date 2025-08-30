return {
  'NickvanDyke/opencode.nvim',
  cond = false, -- Not fonctional yet
  dependencies = {
    'folke/snacks.nvim',
  },
  ---@type opencode.Config
  opts = {},
  -- stylua: ignore
  keys = {
    { '<leader>ct', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
    { '<leader>ce', function() require('opencode').ask('@selection') end, desc = 'OpenCode Send Selection', mode = { 'n', 'v' }, },
    { '<leader>cf', function() require('opencode').ask('@file') end, desc = 'OpenCode Send File', },
    { '<leader>cl', function() require('opencode').ask('@diagnostics') end, desc = 'OpenCode Send Errors', },
  },
}
