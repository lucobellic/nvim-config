return {
  {
    'huynle/ogpt.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    cmd = { 'OGPT', 'OGPTRun' },
    opts = {
      default_provider = 'openai',
      providers = {
        openai = {
          enabled = true,
          model = 'gpt-4-turbo-preview',
        },
      },
      edgy = true,
      single_window = false, -- setting to true doesn't work
      popup = {
        win_options = {
          wrap = true,
        },
      },
      popup_layout = {
        default = 'center',
      },
      chat = {
        question_sign = '',
        answer_sign = '',
      },
    },
  },
}
