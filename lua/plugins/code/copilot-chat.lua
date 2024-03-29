return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>co'] = { name = 'copilot' },
      },
    },
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    opts = {
      show_help = false,
      window = {
        layout = 'vertical',
      },
    },
    cmd = { 'CopilotChat' },
    keys = {
      { '<leader>coc', '<cmd>CopilotChat<CR>', desc = 'Copilot Chat', mode = { 'n', 'v' } },
      -- Quick chat with Copilot
      {
        '<leader>coq',
        function()
          local input = vim.fn.input('Quick Chat: ')
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'CopilotChat Quick chat',
      },
      -- Show help actions with telescope
      {
        '<leader>coh',
        function()
          local actions = require('CopilotChat.actions')
          require('CopilotChat.integrations.telescope').pick(actions.help_actions())
        end,
        desc = 'CopilotChat Help Actions',
      },
      -- Show prompts actions with telescope
      {
        '<leader>cop',
        function()
          local actions = require('CopilotChat.actions')
          require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
        end,
        desc = 'CopilotChat Prompt Actions',
      },
      { '<leader>coe', '<cmd>CopilotChatExplain<CR>', desc = 'CopilotChat Explain', mode = { 'n', 'v' } },
      { '<leader>cot', '<cmd>CopilotChatTests<CR>', desc = 'CopilotChat Tests', mode = { 'n', 'v' } },
      { '<leader>cof', '<cmd>CopilotChatFix<CR>', desc = 'CopilotChat Fix', mode = { 'n', 'v' } },
      { '<leader>cod', '<cmd>CopilotChatDocs<CR>', desc = 'CopilotChat Docs', mode = { 'n', 'v' } },
      { '<leader>coo', '<cmd>CopilotChatOptimize<CR>', desc = 'CopilotChat Optimize', mode = { 'n', 'v' } },
      { '<leader>cos', '<cmd>CopilotChatCommitStaged<CR>', desc = 'CopilotChat Commit Staged', mode = { 'n', 'v' } },
      { '<leader>cop', '<cmd>CopilotChatPromptActions<CR>', desc = 'CopilotChat Prompt Actions', mode = { 'n', 'v' } },
      { '<leader>coq', '<cmd>CopilotChatQuickChat<CR>', desc = 'CopilotChat Quick Chat', mode = { 'n', 'v' } },
    },
  },
}
