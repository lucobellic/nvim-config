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
      },
    },
  },
  {
    'tsakirist/telescope-lazy.nvim',
    cmd = { 'Telescope' },
    config = function()
      LazyVim.on_load('telescope.nvim', function() require('telescope').load_extension('lazy') end)
    end,
  },
  {
    'aaronhallaert/advanced-git-search.nvim',
    cmd = { 'AdvancedGitSearch' },
    config = function()
      LazyVim.on_load('telescope.nvim', function() require('telescope').load_extension('advanced_git_search') end)
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      { '<leader>gc', false },
      { '<leader>gs', false },
      { '<leader>fF', false },
      { '<leader>sl', false },
      { '<c-/>', false },
      { '<leader><leader>', false },
      {
        '<leader>fi',
        function() require('telescope.builtin').symbols({ source = { 'gitmoji' } }) end,
        desc = 'Find Gitmoji',
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
            ['<c-l>'] = function(...) require('telescope.actions').smart_send_to_loclist(...) end,
            ['<esc>'] = function(...) require('telescope.actions').close(...) end,
            ['<C-p>'] = function(...) require('telescope.actions.layout').toggle_preview(...) end,
            ['<RightMouse>'] = function(...) require('telescope.actions').close(...) end,
            ['<LeftMouse>'] = function(...) require('telescope.actions').select_default(...) end,
            ['<ScrollWheelDown>'] = function(...) require('telescope.actions').move_selection_next(...) end,
            ['<ScrollWheelUp>'] = function(...) require('telescope.actions').move_selection_previous(...) end,
            ['<S-up>'] = function(...) require('telescope.actions').cycle_history_prev(...) end,
            ['<S-down>'] = function(...) require('telescope.actions').cycle_history_next(...) end,
            ['<C-k>'] = function(...) require('telescope.actions').move_selection_previous(...) end,
            ['<C-j>'] = function(...) require('telescope.actions').move_selection_next(...) end,
            ['<C-h>'] = cycle_layout,
          },
          n = {
            ['<c-t>'] = function(...) require('trouble.sources.telescope').open(...) end,
            ['<c-l>'] = function(...) require('telescope.actions').smart_send_to_loclist(...) end,
            ['<C-p>'] = function(...) require('telescope.actions.layout').toggle_preview(...) end,
            ['<C-k>'] = function(...) require('telescope.actions').move_selection_previous(...) end,
            ['<C-j>'] = function(...) require('telescope.actions').move_selection_next(...) end,
            ['<C-h>'] = cycle_layout,
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
        lsp_references = {
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
