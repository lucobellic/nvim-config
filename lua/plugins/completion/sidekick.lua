return {
  'folke/sidekick.nvim',
  ---@type sidekick.Config
  keys = {
    {
      '<leader>ae',
      function()
        local is_enabled = vim.lsp.inline_completion.is_enabled()
        if is_enabled then
          vim.notify('Disabled copilot', vim.log.levels.WARN, { title = 'copilot' })
          vim.lsp.enable('copilot', false)
          vim.lsp.inline_completion.enable(false)
        else
          vim.notify('Enabled copilot', vim.log.levels.INFO, { title = 'copilot' })
          vim.lsp.enable('copilot')
          vim.lsp.inline_completion.enable(true)
        end
      end,
      mode = { 'n' },
      desc = 'Copilot enable',
    },
  },
  opts = {
    nes = {
      enabled = function(buf)
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
        return vim.lsp.inline_completion.is_enabled() and buftype ~= 'nofile' and buftype ~= 'terminal'
      end,
      -- trigger = { events = { 'InsertLeave', 'TextChanged', 'User SidekickNesDone' } },
      -- clear = { events = { 'TextChangedI', 'InsertEnter' } },
    },
  },
}
