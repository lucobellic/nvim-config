return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    enabled = false,
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    opts = {
      show_help = false,
      model = 'gpt-4o',
      auto_insert_mode = false,
      question_header = '``` ```', -- Header to use for user questions
      answer_header = '``` ```', -- Header to use for AI answers
      error_header = '``` ```', -- Header to use for errors
      window = {
        layout = 'vertical',
      },
      mappings = {
        reset = {
          normal = '<C-x>',
          insert = '<C-x>',
        },
      },
      prompts = {
        Grammar = {
          prompt = '/COPILOT_INSTRUCTIONS Correct the grammar and spelling of the sentence.',
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
      { '<leader>ar', '<cmd>CopilotChatReview<CR>', desc = 'Review (CopilotChat)', mode = { 'n', 'v' } },
      { '<leader>ag', '<cmd>CopilotChatGrammar<CR>', desc = 'Grammar (CopilotChat)', mode = { 'n', 'v' } },
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
