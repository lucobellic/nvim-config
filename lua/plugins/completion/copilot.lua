return {
  {
    'zbirenbaum/copilot.lua',
    enabled = false,
  },
  {
    'lucobellic/copilot-nes.nvim',
    enabled = false,
    dev = true,
    init = function()
      local augroup = vim.api.nvim_create_augroup('CopilotNesLazyLoad', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = augroup,
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == 'copilot-language-server' then
            require('lazy').load({ plugins = { 'lucobellic/copilot-nes.nvim' } })
            vim.api.nvim_clear_autocmds({ group = augroup })
          end
        end,
      })
    end,
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
  {
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
        trigger = { events = { 'ModeChanged i:n', 'TextChanged', 'User SidekickNesDone' } },
      },
    },
  },
}
