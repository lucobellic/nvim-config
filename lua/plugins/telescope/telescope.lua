return {
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
