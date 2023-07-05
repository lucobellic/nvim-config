return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'folke/trouble.nvim' },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        config = function()
          require('telescope').load_extension('live_grep_args')
        end
      },
      { 'nvim-telescope/telescope-symbols.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim' },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      {
        'nvim-telescope/telescope-smart-history.nvim',
        config = function()
          require('telescope').load_extension('smart_history')
        end
      },
      {
        'tsakirist/telescope-lazy.nvim',
        config = function()
          require('telescope').load_extension('lazy')
        end
      },
    },
    keys = {
      {
        '<leader>FF',
        ':<C-u>:Files<cr>',
        desc =
        'Find All File'
      },
      {
        '<leader>FL',
        function()
          require('telescope').extensions.live_grep_args.live_grep_args()
        end,
        desc = 'Search Workspace'
      },
      {
        '<C-f>',
        function()
          require('telescope').extensions.live_grep_args.live_grep_args()
        end,
        desc = 'Search Workspace'
      },
      {
        '<leader>fb',
        function()
          require('telescope.builtin').buffers()
        end,
        desc =
        'Find Buffer'
      },
      {
        '<leader>fi',
        function()
          require('telescope.builtin').symbols({ source = { 'emoji', 'kaomoji', 'gitmoji' } })
        end,
        desc = 'Find Emoji'
      },
      { '<leader>fc',  function() require('telescope.builtin').commands() end,   desc = 'Find Commands' },
      { '<leader>ff',  function() require('telescope.builtin').find_files() end, desc = 'Find Files' },
      { '<C-p>',       function() require('telescope.builtin').find_files() end, desc = 'Find Files' },
      { '<leader>fF',  ':<C-u>:Files<cr>',                                       desc = 'Find All File' },
      { '<leader>fgs', function() require('telescope.builtin').git_status() end, desc = 'Git Status' },
      { '<leader>fk',  function() require('telescope.builtin').keymaps() end,    desc = 'Find Keymaps' },
      { '<leader>fm',  function() require('telescope.builtin').marks() end,      desc = 'Find Marks' },

      -- Obsidian
      { '<leader>fof', ':ObsidianQuickSwitch<cr>',                               desc = 'Obsidian Find Files' },
      { '<leader>fow', ':ObsidianSearch<cr>',                                    desc = 'Obsidian Search' },
      { '<leader>fr',  function() require('telescope.builtin').oldfiles() end,   desc = 'Find Recent File' },
      {
        '<leader>fw',
        function() require('telescope.builtin').grep_string({ default_text = vim.fn.expand('<cword>') }) end,
        desc = 'Find Word'
      },
      {
        '<leader>fy',
        function() require('telescope').extensions.yank_history.yank_history() end,
        desc = 'Yank History'
      },
      {
        '<leader>fs',
        '<cmd>PersistenceLoadSession<cr>',
        desc =
        'Load session'
      },

      -- LSP
      {
        '<leader>flr',
        function() require('telescope.builtin').lsp_references() end,
        desc =
        'Find References'
      },
      {
        '<leader>fld',
        function() require('telescope.builtin').lsp_definitions() end,
        desc =
        'Find Definitions'
      },
      {
        '<leader>fli',
        function() require('telescope.builtin').lsp_implementations() end,
        desc =
        'Find Implementations'
      },

      -- Symbols
      {
        '<leader>flss',
        function() require('telescope.builtin').lsp_document_symbols() end,
        desc =
        'Find Document Symbols'
      },
      {
        '<leader>flsd',
        function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
        desc =
        'Find Workspace Symbols'
      },
      {
        '<leader>flsw',
        function() require('telescope.builtin').lsp_workspace_symbols() end,
        desc =
        'Find Dynamic Workspace Symbols'
      },
      {
        '<leader>flt',
        function() require('telescope.builtin').lsp_type_definitions() end,
        desc =
        'Find Type Definitions'
      },

      -- Calls
      {
        '<leader>flci',
        function() require('telescope.builtin').lsp_incoming_calls() end,
        desc =
        'Find Incoming Calls'
      },
      {
        '<leader>flco',
        function() require('telescope.builtin').lsp_outgoing_calls() end,
        desc =
        'Find Outgoing Calls'
      },
    },
    opts = require('plugins.telescope.telescope'),
  },

  {
    'stevearc/dressing.nvim',
    opts = {
      select = {
        format_item_override = {
          ['legendary.nvim'] = function(items)
            local values = require('legendary.ui.format').default_format(items)
            return string.format("%-20s • %-20s", values[2], values[3])
          end
        }
      }
    }
  },

  {
    'jackMort/ChatGPT.nvim',
    event = 'VeryLazy',
    keys = {
      { "<leader>ce", function() require('chatgpt').edit_with_instructions() end, desc = "ChatGPT edit with instructions" },
      { "<leader>cg", ":ChatGPT<cr>",                                             desc = "ChatGPT" }
    },
    opts = {
      chat = {
        keymaps = {
          close = { "<C-c>", "q" },
          yank_last = "<C-y>",
          yank_last_code = "<C-k>",
          scroll_up = "<C-u>",
          scroll_down = "<C-d>",
          toggle_settings = "<C-o>",
          new_session = "<C-n>",
          cycle_windows = "<Tab>",
          select_session = "<Space>",
          rename_session = "r",
          delete_session = "d",
        },
      }
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-telescope/telescope.nvim'
    },
  },
}
