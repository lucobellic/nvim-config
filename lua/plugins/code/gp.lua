return {
  'robitx/gp.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>cg', '<cmd>GpChatToggle<cr>', desc = 'Gp Chat Toggle' },
  },
  opts = {
    openai_api_key = os.getenv('OPENAI_API_KEY'),
    chat_user_prefix = ' ',
    chat_assistant_prefix = { ' ', '[{{agent}}]' },
  },
}
