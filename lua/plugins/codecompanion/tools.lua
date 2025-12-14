return {
  'olimorris/codecompanion.nvim',
  opts = {
    interactions = {
      chat = {
        tools = {
          ['insert_edit_into_file'] = {
            opts = {
              require_approval_before = {
                buffer = false,
                file = false,
              },
              require_confirmation_after = false,
            },
          },
          opts = {
            default_tools = { 'code_execution', 'full_stack_dev', 'memory' },
            auto_submit_errors = true, -- Send any errors to the LLM automatically
            auto_submit_success = true, -- Send any successful output to the LLM automatically
          },
        },
      },
    },
  },
}
