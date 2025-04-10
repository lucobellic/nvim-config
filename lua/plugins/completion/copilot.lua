local function suggestion_key_fallback(key, action)
  local copilot_suggestion = require('copilot.suggestion')
  if copilot_suggestion.is_visible() then
    copilot_suggestion[action]()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'n', false)
  end
end

-- Enable Copilot keys only if nvim-cmp is not enabled
local get_keys = function()
  local keys = not vim.g.ai_cmp
      and {
        {
          '<Tab>',
          function() suggestion_key_fallback('<Tab>', 'accept') end,
          desc = 'Copilot accept',
          mode = 'i',
        },
      }
    or {}

  return vim.list_extend(keys, {
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
      desc = 'Copilot next',
      mode = 'i',
    },
  })
end

return {
  {
    'zbirenbaum/copilot.lua',
    enabled = vim.g.suggestions == 'copilot',
    keys = get_keys(),
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
      filetypes = {
        ['*'] = true,
        ['.'] = true,
      },
      server_opts_overrides = {
        settings = {
          advanced = {
            inlineSuggestCount = 3,
          },
        },
      },
      copilot_model = 'gpt-4o-copilot',
      should_attach = function() return true end,
    },
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

      if vim.env.INSIDE_DOCKER then
        table.insert(vim.g.copilot_workspace_folders, '~/rapidash')
      end
    end,
    config = function()
      if vim.env.INSIDE_DOCKER then
        vim.cmd('Copilot disable')
      end
    end,
  },
}
