local border_style = vim.g.border.style == 'rounded' and 'rounded' or ' '

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>cc'] = { name = 'chatgpt' },
      },
    },
  },
  {
    'jackMort/ChatGPT.nvim',
    name = 'chatgpt',
    enabled = not vim.g.started_by_firenvim,
    event = 'VeryLazy',
    cmd = { 'ChatGPT', 'ChatGPTRun' },
    keys = {
      -- { '<leader>cg', '<cmd>ChatGPT<CR>', desc = 'ChatGPT', mode = { 'n', 'v' } },
      { '<leader>ccc', '<cmd>ChatGPT<CR>', desc = 'ChatGPT', mode = { 'n', 'v' } },
      { '<leader>cct', '<cmd>ChatGPTRun translate<CR>', desc = 'ChatGPT Translate', mode = { 'n', 'v' } },
      { '<leader>cck', '<cmd>ChatGPTRun keywords<CR>', desc = 'ChatGPT Keywords', mode = { 'n', 'v' } },
      { '<leader>ccd', '<cmd>ChatGPTRun docstring<CR>', desc = 'ChatGPT Docstring', mode = { 'n', 'v' } },
      { '<leader>cca', '<cmd>ChatGPTRun add_tests<CR>', desc = 'ChatGPT Add Tests', mode = { 'n', 'v' } },
      { '<leader>cco', '<cmd>ChatGPTRun optimize_code<CR>', desc = 'ChatGPT Optimize Code', mode = { 'n', 'v' } },
      { '<leader>ccs', '<cmd>ChatGPTRun summarize<CR>', desc = 'ChatGPT Summarize', mode = { 'n', 'v' } },
      { '<leader>ccf', '<cmd>ChatGPTRun fix_bugs<CR>', desc = 'ChatGPT Fix Bugs', mode = { 'n', 'v' } },
      { '<leader>ccx', '<cmd>ChatGPTRun explain_code<CR>', desc = 'ChatGPT Explain Code', mode = { 'n', 'v' } },
      { '<leader>ccr', '<cmd>ChatGPTRun roxygen_edit<CR>', desc = 'ChatGPT Roxygen Edit', mode = { 'n', 'v' } },
      {
        '<leader>cce',
        '<cmd>ChatGPTEditWithInstruction<CR>',
        desc = 'ChatGPT Edit with instruction',
        mode = { 'n', 'v' },
      },
      {
        '<leader>cca',
        '<cmd>ChatGPTRun grammar_correction<CR>',
        desc = 'ChatGPT Grammar Correction',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ccl',
        '<cmd>ChatGPTRun code_readability_analysis<CR>',
        desc = 'ChatGPT Code Readability Analysis',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      edit_with_instructions = {
        diff = true,
        keymaps = {
          close = '<C-q>',
          cycle_windows = '<Tab>',
        },
      },
      chat = {
        border_left_sign = '',
        border_right_sign = '',
        keymaps = {
          close = '<C-q>',
          cycle_windows = '<Tab>',
        },
        session_window = {
          border = vim.g.border.style,
        },
      },
      popup_window = { border = { style = vim.g.border.style } },
      system_window = { border = { style = vim.g.border.style } },
      help_window = { border = { style = vim.g.border.style } },
      settings_window = { border = { style = vim.g.border.style } },
      popup_input = { border = { style = vim.g.border.style } },
      openai_params = {
        model = 'gpt-4o',
        max_tokens = 3000,
      },
      openai_edit_params = {
        model = 'gpt-4o',
      },
    },
    config = function(_, opts) require('chatgpt').setup(opts) end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'folke/trouble.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
}
