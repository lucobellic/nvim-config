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
      default_provider = 'gemini',
      edgy = true,
      single_window = true,
      popup = {
        win_options = {
          wrap = true,
        },
      },
      popup_layout = {
        default = 'center',
        center = {
          width = 10,
          height = 10,
        },
      },
    },
  },
}
