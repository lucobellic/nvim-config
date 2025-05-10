return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>i', group = 'avante', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'yetone/avante.nvim',
    enabled = false,
    lazy = false,
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
    },
    keys = {
      { '<leader>ir', '<cmd>AvanteClear<cr>', desc = 'Avante Clear' },
    },
    opts = {
      provider = 'copilot',
      copilot = { model = 'claude-3.7-sonnet' },
      auto_suggestions_provider = 'ollama',
      cursor_applying_provider = 'claude-3.5-sonnet',
      vendors = {
        ['claude-3.5-sonnet'] = {
          __inherited_from = 'copilot',
          model = 'claude-3.5-sonnet',
        },
      },
      behaviour = {
        auto_apply_diff_after_generation = false,
        auto_suggestions = false, -- Experimental stage
        enable_claude_text_editor_tool_mode = false, -- Only support with claude provider
        enable_cursor_planning_mode = true,
        support_paste_from_clipboard = false,
      },
      mappings = {
        ask = '<leader>ia',
        edit = '<leader>ii',
        refresh = '<leader>ir',
        focus = '<leader>ib',
        toggle = {
          default = '<leader>it',
          debug = '<leader>id',
          hint = '<leader>ih',
          suggestion = '<leader>is',
          repomap = '<leader>iR',
        },
        files = {
          add_current = '<leader>ic', -- Add current buffer to selected files
        },
        sidebar = {
          switch_windows = '<leader>i_',
          reverse_switch_windows = '<leader>i*',
        },
        select_model = '<leader>i?', -- Select model command
        select_history = '<leader>ih', -- Select history command
      },
      windows = {
        position = 'bottom',
        height = 100,
        sidebar_header = { enabled = false },
        edit = { border = vim.g.border.style, start_insert = false },
        ask = { border = vim.g.border.style, start_insert = false },
      },
      diff = { autojump = false },
      hints = { enabled = false },
    },
  },
}
