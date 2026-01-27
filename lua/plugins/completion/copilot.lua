return {
  {
    'zbirenbaum/copilot.lua',
    enabled = false,
  },
  {
    'lucobellic/copilot-nes.nvim',
    dev = true,
    lazy = false,
    keys = {
      { '<Tab>', function() return require('copilot-nes').update() end, desc = 'Copilot NES Update' },
      {
        '<Esc>',
        function()
          if require('copilot-nes').have() then
            require('copilot-nes').clear()
            return
          end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
        end,
        desc = 'Copilot NES clear',
      },
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
        desc = 'Copilot NES enable',
      },
      {
        '<leader>uN',
        function()
          if require('copilot-nes').enabled then
            vim.notify('Disabled NES', vim.log.levels.WARN, { title = 'Copilot NES' })
            require('copilot-nes').enable(false)
          else
            vim.notify('Enabled NES', vim.log.levels.INFO, { title = 'Copilot NES' })
            require('copilot-nes').enable()
          end
        end,
        desc = 'Copilot NES toggle',
      },
    },
    opts = {
      signs = {
        enabled = true,
        icon = '',
      },
      inline = {
        enabled = true,
      },
    },
  },
}
