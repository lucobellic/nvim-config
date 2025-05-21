return {
  {
    'copilotlsp-nvim/copilot-lsp',
    enabled = false, -- Too slow and do not use copilot lsp handleNextEditRequest
    lazy = false,
    dependencies = {
      {
        'mason-org/mason.nvim',
        optional = true,
        lazy = false,
        opts = { ensure_installed = { 'copilot-language-server' } },
      },
    },
    keys = {
      {
        '<S-Tab>',
        function()
          nes = require('copilot-lsp.nes')
          if not nes.walk_cursor_start_edit() then
            if nes.apply_pending_nes() then
              nes.walk_cursor_end_edit()
            end
          end
        end,
        mode = { 'i', 'n', 'v' },
        desc = 'Copilot NES',
      },
    },
    opts = {},
    init = function() vim.g.copilot_nes_debounce = 500 end,
    config = function()
      vim.lsp.config('copilot_ls', {})
      vim.lsp.enable('copilot_ls')
    end,
  },
}
