local function suggestion_key_fallback(key, action)
  local copilot_suggestion = require('copilot.suggestion')
  if copilot_suggestion.is_visible() then
    copilot_suggestion[action]()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'n', false)
  end
end

return {
  {
    'zbirenbaum/copilot.lua',
    enabled = (vim.fn.isdirectory('/data/data/com.termux') ~= 1),
    dependencies = {
      'copilotlsp-nvim/copilot-lsp',
    },
    cond = vim.g.suggestions == 'copilot' and not vim.g.vscode,
    keys = {
      {
        '<leader>ae',
        function()
          local is_disabled = require('copilot.client').is_disabled()
          if is_disabled then
            vim.notify('Enabled copilot', vim.log.levels.INFO, { title = 'copilot' })
            vim.cmd('Copilot enable')
          else
            vim.notify('Disabled copilot', vim.log.levels.WARN, { title = 'copilot' })
            vim.cmd('Copilot disable')
          end
        end,
        mode = { 'n' },
        desc = 'Copilot enable',
      },
      {
        '<C-l>',
        function() suggestion_key_fallback('<C-l>', 'next') end,
        desc = 'Copilot next',
        mode = 'i',
      },
      {
        '<C-h>',
        function() suggestion_key_fallback('<C-h>', 'prev') end,
        desc = 'Copilot prev',
        mode = 'i',
      },
      {
        '<A-l>',
        function() suggestion_key_fallback('<A-l>', 'accept_word') end,
        desc = 'Copilot accept work',
        mode = 'i',
      },
    },
    opts = {
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = false,
          next = false,
          prev = false,
        },
      },
      nes = {
        enabled = true,
        auto_trigger = false,
        keymap = {
          accept_and_goto = false,
          accept = '<S-Tab>',
          dismiss = '<esc>',
        },
      },
      filetypes = {
        ['*'] = true,
        ['.'] = true,
      },
      server_opts_overrides = {
        settings = {
          telemetry = { telemetryLevel = 'off' },
          advanced = { inlineSuggestCount = 3 },
        },
      },
      copilot_model = 'gpt-4o-copilot',
      should_attach = function(bufnr)
        local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
        return buftype ~= 'terminal' and buftype ~= 'help' and buftype ~= 'nowrite' and buftype ~= 'prompt'
      end,
    },
    config = function(_, opts)
      require('copilot').setup(opts)
      if vim.env.INSIDE_DOCKER then
        vim.cmd('Copilot disable')
      end
    end,
  },
  {
    'github/copilot.vim',
    enabled = false,
    event = 'BufEnter',
    keys = {
      {
        '<c-l>',
        function() vim.fn['copilot#Next']() end,
        desc = 'Copilot next',
        mode = 'i',
      },
      {
        '<c-h>',
        function() vim.fn['copilot#Prev']() end,
        desc = 'Copilot prev',
        mode = 'i',
      },
      {
        '<a-l>',
        '<Plug>(copilot-accept-word)',
        desc = 'Copilot accept word',
        mode = 'i',
      },
    },
    init = function()
      vim.g.copilot_workspace_folders = { '~/.config/nvim' }
      vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
      vim.g.copilot_integration_id = 'vscode-chat'
    end,
    config = function()
      if vim.env.INSIDE_DOCKER then
        vim.cmd('Copilot disable')
      end
    end,
  },
}
