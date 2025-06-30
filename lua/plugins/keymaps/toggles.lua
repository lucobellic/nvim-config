return {
  'folke/which-key.nvim',
  keys = {
    { '<leader>uS', '<cmd>ToggleAutoSave<cr>', desc = 'Toggle Auto Save' },
    {
      '<leader>uW',
      function()
        require('windows.autowidth').toggle()
        local is_enabled = require('windows.config').autowidth.enable
        local text = is_enabled and 'Enabled' or 'Disabled'
        local level = is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(text .. ' autowidth', level, { title = 'Options' })
      end,
      repeatable = true,
      desc = 'Windows Toggle Autowidth',
    },
    {
      '<leader>uh',
      function()
        local is_enabled = vim.lsp.inlay_hint.is_enabled()
        vim.lsp.inlay_hint.enable(not is_enabled)
        local text = (not is_enabled and 'Enabled' or 'Disabled') .. ' inlay hints'
        local level = not is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(text, level, { title = 'Options' })
      end,
      repeatable = true,
      desc = 'Toggle Inlay Hints',
    },
  },
}
