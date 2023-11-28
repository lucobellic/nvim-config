return {
  'jackMort/ChatGPT.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>ce',
      function()
        require('chatgpt').edit_with_instructions()
      end,
      desc = 'ChatGPT edit with instructions',
    },
    { '<leader>cg', '<cmd>ChatGPT<cr>', desc = 'ChatGPT' },
  },
  opts = {
    chat = {
      keymaps = {
        close = { '<C-c>', '<C-q>' },
        yank_last = '<C-y>',
        yank_last_code = '<C-k>',
        scroll_up = '<C-u>',
        scroll_down = '<C-d>',
        toggle_settings = '<C-o>',
        new_session = '<C-n>',
        cycle_windows = '<Tab>',
        select_session = '<Space>',
        rename_session = 'r',
        delete_session = 'd',
      },
    },
    openai_params = {
      model = 'gpt-4-1106-preview',
      frequency_penalty = 0,
      presence_penalty = 0,
      max_tokens = 3000,
      temperature = 0,
      top_p = 1,
      n = 1,
    },
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim',
  },
}
