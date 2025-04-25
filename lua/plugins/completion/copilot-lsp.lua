return {
  'copilotlsp-nvim/copilot-lsp',
  enabled = false,
  lazy = false,
  keys = {
    {
      '<tab>',
      function() require('copilot-lsp.nes').apply_pending_nes() end,
      mode = { 'n', 'v' },
      desc = 'Copilot NES',
    },
  },
  opts = {},
  init = function() vim.g.copilot_nes_debounce = 500 end,
  config = function() vim.lsp.enable('copilot') end,
}
