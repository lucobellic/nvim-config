return {
  'robitx/gp.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>cg', '<cmd>GpChatToggle<cr>', desc = 'Gp Chat Toggle' },
  },
  opts = {
    agents = {
      { name = 'ChatGPT3-5', chat = false, command = false },
      {
        name = 'ChatGPT4',
        chat = true,
        command = false,
        -- string with model name or table with model name and parameters
        model = { model = 'gpt-4-1106-preview', temperature = 1.1, top_p = 1 },
        -- system prompt (use this to specify the persona/role of the AI)
        system_prompt = 'For all the following questions, provide short answers without explanations.\n',
        'Prefer usage of bullet points if explanations are needed.',
      },
    },
    openai_api_key = os.getenv('OPENAI_API_KEY'),
    chat_user_prefix = ' ',
    chat_assistant_prefix = { ' ', '[{{agent}}]' },
  },
}
