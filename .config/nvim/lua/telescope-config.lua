require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--colo r=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },

    show_line = false;
    prompt_title = "";
    results_title = "";
    preview_title = "";

    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",

    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "vertical",
    layout_config = {
      vertical = {
        width = 0.65,
        height_padding = 5,
        preview_height = 0.5,
        mirror = true,
      },
    },

    file_ignore_patterns = {},
    winblend = 20,
    previewer = false,
    -- results_width = 0.8,
    borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    color_devicons = true,
    -- use_less = true,
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
  }
}

local actions = require('telescope.actions')

