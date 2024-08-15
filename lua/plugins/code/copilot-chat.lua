return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    opts = {
      show_help = false,
      model = 'gpt-4o',
      question_header = '``` ```', -- Header to use for user questions
      answer_header = '``` ```', -- Header to use for AI answers
      error_header = '``` ```', -- Header to use for errors Worng
      window = {
        layout = 'vertical',
      },
      mappings = {
        reset = {
          normal = '<C-x>',
          insert = '<C-x>',
        },
      },
    },
    cmd = {
      'CopilotChat',
      'CopilotChatOpen',
      'CopilotChatClose',
      'CopilotChatToggle',
      'CopilotChatReset',
      'CopilotChatSave',
      'CopilotChatLoad',
      'CopilotChatDebugInfo',
      -- Commands from default prompts
      'CopilotChatExplain',
      'CopilotChatReview',
      'CopilotChatFix',
      'CopilotChatOptimize',
      'CopilotChatDocs',
      'CopilotChatTests',
      'CopilotChatFixDiagnostic',
      'CopilotChatCommit',
      'CopilotChatCommitStaged',
    },
    keys = {
      -- Show help actions with telescope
      {
        '<leader>ah',
        function()
          local actions = require('CopilotChat.actions')
          require('CopilotChat.integrations.telescope').pick(actions.help_actions())
        end,
        desc = 'CopilotChat Help Actions',
      },
      { '<leader>ae', '<cmd>CopilotChatExplain<CR>', desc = 'Explain (CopilotChat)', mode = { 'n', 'v' } },
      { '<leader>at', '<cmd>CopilotChatTests<CR>', desc = 'Tests (CopilotChat)', mode = { 'n', 'v' } },
      { '<leader>af', '<cmd>CopilotChatFix<CR>', desc = 'Fix (CopilotChat)', mode = { 'n', 'v' } },
      { '<leader>ac', '<cmd>CopilotChatDocs<CR>', desc = 'Docs (CopilotChat)', mode = { 'n', 'v' } },
      { '<leader>ao', '<cmd>CopilotChatOptimize<CR>', desc = 'Optimize (CopilotChat)', mode = { 'n', 'v' } },
      { '<leader>as', '<cmd>CopilotChatCommitStaged<CR>', desc = 'Commit Staged (CopilotChat)', mode = { 'n', 'v' } },
    },
    config = function(_, opts)
      require('CopilotChat').setup(opts)
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-*',
        callback = function() vim.o.number = false end,
      })
    end,
  },
}
