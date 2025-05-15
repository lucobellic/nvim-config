return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'ravitemer/codecompanion-history.nvim',
  },
  opts = {
    extensions = {
      history = {
        enabled = true,
        opts = {
          keymap = '<localleader>hh',
          auto_generate_title = true,
          continue_last_chat = false,
          delete_on_clearing_chat = true,
          picker = 'snacks',
          enable_logging = false,
          dir_to_save = vim.fn.stdpath('data') .. '/codecompanion-history',
          auto_save = true,
          save_chat_keymap = '<localleader>hs',
        },
      },
    },
  },
}
