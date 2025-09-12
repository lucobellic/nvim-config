return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      chat = {
        tools = {
          ['insert_edit_into_file'] = {
            opts = {
              requires_approval = {
                buffer = false,
                file = false,
              },
              user_confirmation = false,
            },
          },
          opts = {
            default_tools = { 'cmd_runner', 'files' },
            auto_submit_errors = true, -- Send any errors to the LLM automatically
            auto_submit_success = true, -- Send any successful output to the LLM automatically
          },
        },
      },
    },
  },
}
