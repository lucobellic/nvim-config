return {
  'folke/which-key.nvim',
  keys = {
    { '<leader>uW', '<cmd>ToggleAutoSave<cr>', desc = 'Toggle Auto Save' },
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
