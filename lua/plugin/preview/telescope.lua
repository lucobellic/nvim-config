local trouble = require('trouble.providers.telescope')
local actions = require("telescope.actions")

require('telescope').load_extension('live_grep_args')
local lga_actions = require("telescope-live-grep-args.actions")
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-t>"] = trouble.smart_open_with_trouble,
        ["<esc>"] = actions.close,
        ["<C-k>"] = lga_actions.quote_prompt(),
        ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
      },
      n = {
        ["<C-t>"] = trouble.smart_open_with_trouble,
      },
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

    path_display = {'smart'},
    show_line = false,
    prompt_title = false,
    results_title = false,
    preview_title = false,
    dynamic_preview_title = false,

    prompt_prefix = "> ",
    selection_caret = "> ",
    entry_prefix = "  ",

    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",


    -- layout_strategy = "vertical",
    layout_strategy = "horizontal",

    layout_config = {
      horizontal = {
        prompt_position = 'top',
        mirror = false,
        preview_width = 0.6
      },
      -- vertical = {
      --   width = 0.65,
      --   height_padding = 5,
      --   preview_height = 0.5,
      --   mirror = true,
      -- },
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
