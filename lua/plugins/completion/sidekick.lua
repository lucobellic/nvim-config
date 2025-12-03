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
          vim.g.suggestions = false
          vim.lsp.enable('copilot', false)
          vim.lsp.inline_completion.enable(false)
        else
          vim.notify('Enabled copilot', vim.log.levels.INFO, { title = 'copilot' })
          vim.g.suggestions = 'copilot'
          vim.lsp.enable('copilot')
          vim.lsp.inline_completion.enable(true)
        end
      end,
      mode = { 'n' },
      desc = 'Copilot enable',
    },
    {
      '<leader>uN',
      function()
        if require('sidekick.nes').enabled then
          vim.notify('Disabled NES', vim.log.levels.WARN, { title = 'Sidekick' })
          require('sidekick.nes').enable(false)
        else
          vim.notify('Enabled NES', vim.log.levels.INFO, { title = 'Sidekick' })
          require('sidekick.nes').enable()
        end
      end,
      desc = 'Sidekick toggle NES',
    },
  },
  opts = {
    nes = {
      enabled = function(buf)
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
        return vim.lsp.inline_completion.is_enabled() and buftype ~= 'nofile' and buftype ~= 'terminal'
      end,
      job = {
        enabled = true,
        run_in_insert = true,
        debounce = 150,
      },
      trigger = { events = { 'InsertLeave', 'TextChanged', 'TextChangedI', 'User SidekickNesDone' } },
      -- clear = { events = { 'TextChangedI', 'InsertEnter' } },
    },
  },
}
