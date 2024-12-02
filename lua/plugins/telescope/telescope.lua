local function get_next_layout(current_layout)
  local layouts = { horizontal = 'center', center = 'vertical', vertical = 'horizontal' }
  return layouts[current_layout]
end

local function cycle_layout(prompt_bufnr)
  local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  picker.layout_strategy = get_next_layout(picker.layout_strategy)
  picker.layout_config = {}
  picker.previewer = picker.all_previewers and picker.all_previewers[1] or nil
  picker:full_layout_update()
end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>fl', group = 'lsp' },
        { '<leader>flc', group = 'calls' },
        { '<leader>fls', group = 'symbols' },
        { '<leader>fo', group = 'obsidian' },
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'BurntSushi/ripgrep' },
      { 'folke/trouble.nvim' },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        config = function() require('telescope').load_extension('live_grep_args') end,
      },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        config = function() require('telescope').load_extension('fzf') end,
      },
      {
        'nvim-telescope/telescope-file-browser.nvim',
        config = function() require('telescope').load_extension('file_browser') end,
      },
      {
        'nvim-telescope/telescope-smart-history.nvim',
        enabled = vim.fn.has('sqlite3') and not jit.os == 'windows',
        dependencies = { 'kkharji/sqlite.lua' },
        config = function() require('telescope').load_extension('smart_history') end,
      },
      {
        'tsakirist/telescope-lazy.nvim',
        config = function() require('telescope').load_extension('lazy') end,
      },
      {
        'aaronhallaert/advanced-git-search.nvim',
        config = function() require('telescope').load_extension('advanced_git_search') end,
      },
      {
        'debugloop/telescope-undo.nvim',
        keys = {
          {
            '<leader>uu',
            function() require('telescope').extensions.undo.undo() end,
            desc = 'Telescope Undo Tree',
          },
        },
        config = function() require('telescope').load_extension('undo') end,
      },
      {
        'nvim-telescope/telescope-dap.nvim',
        keys = {
          {
            '<leader>fdc',
            function() require('telescope').extensions.dap.commands({}) end,
            desc = 'Dap Find Commands',
          },
          {
            '<leader>fds',
            function() require('telescope').extensions.dap.configurations({}) end,
            desc = 'Dap Find Configurations',
          },
          {
            '<leader>fdb',
            function() require('telescope').extensions.dap.list_breakpoints({}) end,
            desc = 'Dap Find Breakpoints',
          },
          {
            '<leader>fdv',
            function() require('telescope').extensions.dap.variables({}) end,
            desc = 'Dap Find Variables',
          },
          {
            '<leader>fdf',
            function() require('telescope').extensions.dap.frames({}) end,
            desc = 'Dap Find Frames',
          },
        },
        config = function() require('telescope').load_extension('dap') end,
      },
    },
    keys = {
      { '<leader>gc', false },
      { '<leader>gs', false },
      { '<leader>fF', false },
      { '<leader>sl', false },
      { '<c-/>', false },
      { '<leader><leader>', false },
      {
        '<leader>fL',
        function() require('telescope').extensions.live_grep_args.live_grep_args({ layout_strategy = 'vertical' }) end,
        desc = 'Search Workspace',
      },
      {
        '<C-f>',
        function() require('telescope').extensions.live_grep_args.live_grep_args({ layout_strategy = 'vertical' }) end,
        desc = 'Search Workspace',
      },
      {
        '<leader>fb',
        function() require('telescope.builtin').buffers() end,
        desc = 'Find Buffer',
      },
      {
        '<leader>fi',
        function() require('telescope.builtin').symbols({ source = { 'gitmoji' } }) end,
        desc = 'Find Emoji',
      },
      {
        '<leader>fc',
        function() require('telescope.builtin').commands() end,
        desc = 'Find Commands',
      },
      {
        '<leader>ff',
        function() require('telescope.builtin').find_files() end,
        desc = 'Find Files',
      },
      {
        '<C-p>',
        function() require('telescope.builtin').find_files() end,
        desc = 'Find Files',
      },
      {
        '<leader>gs',
        function() require('telescope.builtin').git_status({ layout_strategy = 'vertical' }) end,
        desc = 'Git Status',
      },
      {
        '<leader>fm',
        function() require('telescope.builtin').marks({ layout_strategy = 'vertical' }) end,
        desc = 'Find Marks',
      },

      -- Obsidian
      { '<leader>fof', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Obsidian Find Files' },
      { '<leader>fow', '<cmd>ObsidianSearch<cr>', desc = 'Obsidian Search' },
      {
        '<leader>fr',
        function() require('telescope.builtin').oldfiles() end,
        desc = 'Find Recent File',
      },
      {
        '<leader>fw',
        function() require('telescope.builtin').grep_string() end,
        mode = { 'n', 'v' },
        desc = 'Find Word',
      },
      {
        '<leader>fs',
        '<cmd>PersistenceLoadSession<cr>',
        desc = 'Load session',
      },

      -- LSP
      {
        '<leader>flr',
        function() require('telescope.builtin').lsp_references() end,
        desc = 'Find References',
      },
      {
        '<leader>fld',
        function() require('telescope.builtin').lsp_definitions() end,
        desc = 'Find Definitions',
      },
      {
        '<leader>fli',
        function() require('telescope.builtin').lsp_implementations() end,
        desc = 'Find Implementations',
      },

      -- Symbols
      {
        '<leader>ss',
        function() require('telescope.builtin').lsp_document_symbols({ symbol_width = 100 }) end,
        desc = 'Search Document Symbols',
      },
      {
        '<leader>sS',
        function()
          require('telescope.builtin').lsp_dynamic_workspace_symbols({
            layout_strategy = 'vertical',
            fname_width = 100,
            symbol_width = 50,
          })
        end,
        desc = 'Search Workspace Symbols',
      },
      {
        '<leader>flt',
        function() require('telescope.builtin').lsp_type_definitions() end,
        desc = 'Find Type Definitions',
      },

      -- Calls
      {
        '<leader>flci',
        function() require('telescope.builtin').lsp_incoming_calls() end,
        desc = 'Find Incoming Calls',
      },
      {
        '<leader>flco',
        function() require('telescope.builtin').lsp_outgoing_calls() end,
        desc = 'Find Outgoing Calls',
      },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ['<c-t>'] = function(...) require('trouble.sources.telescope').open(...) end,
            ['<c-l>'] = require('telescope.actions').smart_send_to_loclist,
            ['<esc>'] = require('telescope.actions').close,
            ['<C-n>'] = require('telescope.actions').select_tab,
            ['<C-b>'] = require('telescope.actions.layout').toggle_preview,
            ['<C-j>'] = cycle_layout,
            ['<RightMouse>'] = require('telescope.actions').close,
            ['<LeftMouse>'] = require('telescope.actions').select_default,
            ['<ScrollWheelDown>'] = require('telescope.actions').move_selection_next,
            ['<ScrollWheelUp>'] = require('telescope.actions').move_selection_previous,
            ['<S-up>'] = require('telescope.actions').cycle_history_prev,
            ['<S-down>'] = require('telescope.actions').cycle_history_next,
          },
          n = {
            ['<c-t>'] = function(...) require('trouble.sources.telescope').open(...) end,
            ['<c-l>'] = require('telescope.actions').smart_send_to_loclist,
            ['<C-n>'] = require('telescope.actions').select_tab,
            ['<C-k>'] = function() require('telescope-live-grep-args.actions').quote_prompt() end,
            ['<C-g>'] = function() require('telescope-live-grep-args.actions').quote_prompt({ postfix = ' --iglob ' }) end,
            ['<C-b>'] = require('telescope.actions.layout').toggle_preview,
            ['<C-j>'] = cycle_layout,
          },
        },
        history = {
          path = vim.fn.stdpath('data') .. '/telescope_history.sqlite3',
          limit = 100,
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },
        path_display = { 'filename_first' },
        prompt_title = false,
        results_title = false,
        preview_title = true,
        dynamic_preview_title = true,
        prompt_prefix = '> ',
        selection_caret = '> ',
        entry_prefix = '  ',
        initial_mode = 'insert',
        selection_strategy = 'reset',
        sorting_strategy = 'ascending',
        layout_strategy = 'center',
        layout_config = {
          horizontal = {
            width = 0.9,
            preview_width = 0.65,
            prompt_position = 'top',
          },
          center = {
            width = 0.6,
            height = 0.5,
            prompt_position = 'top',
            preview_cutoff = 999, -- disable previewer
          },
          vertical = {
            width = 0.9,
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
        borderchars = vim.g.border.borderchars,
        color_devicons = true,
        -- use_less = true,
        set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
      },
      pickers = {
        grep_string = {
          layout_strategy = 'vertical',
        },
        help_tags = {
          layout_strategy = 'vertical',
        },
        diagnostics = {
          layout_strategy = 'vertical',
        },
      },
      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
      },
    },
  },
}
