return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>F'] = { name = '+file/find' },
        ['<leader>fg'] = { name = '+git' },
        ['<leader>fl'] = { name = '+lsp' },
        ['<leader>flc'] = { name = '+calls' },
        ['<leader>fls'] = { name = '+symbols' },
        ['<leader>fo'] = { name = '+obsidian' },
      },
    },
  },
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
        ':<C-u>:FzfLua files<cr>',
        desc = 'Find All Files'
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
        desc = 'Find Buffer'
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
      { '<leader>fF',  ':<C-u>:FzfLua files<cr>',                                desc = 'Find All File' },
      { '<leader>fgs', function() require('telescope.builtin').git_status() end, desc = 'Git Status' },
      { '<leader>fk',  function() require('telescope.builtin').keymaps() end,    desc = 'Find Keymaps' },
      { '<leader>fm',  function() require('telescope.builtin').marks() end,      desc = 'Find Marks' },

      -- Obsidian
      { '<leader>fof', ':ObsidianQuickSwitch<cr>',                               desc = 'Obsidian Find Files' },
      { '<leader>fow', ':ObsidianSearch<cr>',                                    desc = 'Obsidian Search' },
      { '<leader>fr',  function() require('telescope.builtin').oldfiles() end,   desc = 'Find Recent File' },
      {
        '<leader>fw',
        function() require('telescope.builtin').grep_string() end,
        mode = { 'n', 'v' },
        desc = 'Find Word'
      },
      {
        '<leader>fs',
        '<cmd>PersistenceLoadSession<cr>',
        desc = 'Load session'
      },

      -- LSP
      {
        '<leader>flr',
        function() require('telescope.builtin').lsp_references() end,
        desc = 'Find References'
      },
      {
        '<leader>fld',
        function() require('telescope.builtin').lsp_definitions() end,
        desc = 'Find Definitions'
      },
      {
        '<leader>fli',
        function() require('telescope.builtin').lsp_implementations() end,
        desc = 'Find Implementations'
      },

      -- Symbols
      {
        '<leader>flss',
        function() require('telescope.builtin').lsp_document_symbols() end,
        desc = 'Find Document Symbols'
      },
      {
        '<leader>flsd',
        function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,
        desc = 'Find Workspace Symbols'
      },
      {
        '<leader>flsw',
        function() require('telescope.builtin').lsp_workspace_symbols() end,
        desc = 'Find Dynamic Workspace Symbols'
      },
      {
        '<leader>flt',
        function() require('telescope.builtin').lsp_type_definitions() end,
        desc = 'Find Type Definitions'
      },

      -- Calls
      {
        '<leader>flci',
        function() require('telescope.builtin').lsp_incoming_calls() end,
        desc = 'Find Incoming Calls'
      },
      {
        '<leader>flco',
        function() require('telescope.builtin').lsp_outgoing_calls() end,
        desc = 'Find Outgoing Calls'
      },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ['<C-t>'] = function(...) require('trouble.providers.telescope').smart_open_with_trouble(...) end,
            ['<esc>'] = require('telescope.actions').close,
            ['<C-k>'] = function() require('telescope-live-grep-args.actions').quote_prompt() end,
            ['<C-g>'] = function() require('telescope-live-grep-args.actions').quote_prompt({ postfix = ' --iglob ' }) end,
            ['<C-n>'] = require('telescope.actions').select_tab,
            ['<C-b>'] = require('telescope.actions.layout').toggle_preview,
            ['<C-x>'] = require('telescope.actions.layout').cycle_layout_next,
            ['<RightMouse>'] = require('telescope.actions').close,
            ['<LeftMouse>'] = require('telescope.actions').select_default,
            ['<ScrollWheelDown>'] = require('telescope.actions').move_selection_next,
            ['<ScrollWheelUp>'] = require('telescope.actions').move_selection_previous,
            ['<S-up>'] = require('telescope.actions').cycle_history_prev,
            ['<S-down>'] = require('telescope.actions').cycle_history_next,
          },
          n = {
            ['<C-t>'] = function(...) require('trouble.providers.telescope').smart_open_with_trouble(...) end,
            ['<C-n>'] = require('telescope.actions').select_tab,
            ['<C-b>'] = require('telescope.actions.layout').toggle_preview,
            ['<C-x>'] = require('telescope.actions.layout').cycle_layout_next,
          },
        },
        history = {
          path = "~/.local/share/nvim/telescope_history.sqlite3",
          limit = 100,
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case'
        },
        show_line = false,
        prompt_title = false,
        results_title = false,
        preview_title = true,
        dynamic_preview_title = true,
        prompt_prefix = "> ",
        selection_caret = "> ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        -- layout_strategy = "horizontal",
        layout_strategy = "vertical",
        layout_config = {
          horizontal = {
            width = 0.8,
            prompt_position = 'top',
            mirror = false,
            preview_width = 0.6
          },
          vertical = {
            width = 0.8,
            height_padding = 0,
            preview_height = 0.70,
            mirror = true,
            prompt_position = 'top',
          },
        },
        file_ignore_patterns = {},
        winblend = vim.o.pumblend,
        preview = { treesitter = { enable = true } },
        -- results_width = 0.8,
        -- borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        color_devicons = true,
        -- use_less = true,
        set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
      }
    }
  }
}
