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
          ['cmd_runner'] = {
            opts = {
              allowed_in_yolo_mode = true,
              require_approval_before = false,
              require_cmd_approval = false,
            },
          },
          ['create_file'] = {
            opts = {
              require_approval_before = false,
              require_cmd_approval = false,
            },
          },
          ['delete_file'] = {
            opts = {
              allowed_in_yolo_mode = true,
              require_approval_before = false,
              require_cmd_approval = false,
            },
          },
          ['file_search'] = { opts = { require_cmd_approval = false } },
          ['grep_search'] = {
            opts = {
              require_approval_before = false,
              require_cmd_approval = false,
            },
          },
          ['memory'] = { opts = { require_approval_before = false } },
          ['read_file'] = {
            opts = {
              require_approval_before = false,
              require_cmd_approval = false,
            },
          },
          opts = {
            default_tools = { 'code_execution', 'full_stack_dev', 'memory' },
            require_approval_before = false,
            require_cmd_approval = false,
            allowed_in_yolo_mode = true,
            auto_submit_errors = true, -- Send any errors to the LLM automatically
            auto_submit_success = true, -- Send any successful output to the LLM automatically
          },
        },
      },
    },
  },
}
