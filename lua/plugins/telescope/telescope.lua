local trouble = require('trouble.providers.telescope')
local actions = require("telescope.actions")
local truncate = require("plenary.strings").truncate

local lga_actions = require("telescope-live-grep-args.actions")
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-t>"] = trouble.smart_open_with_trouble,
        ["<esc>"] = actions.close,
        ["<C-k>"] = lga_actions.quote_prompt(),
        ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
        ["<C-n>"] = actions.select_tab,
      },
      n = {
        ["<C-t>"] = trouble.smart_open_with_trouble,
        ["<C-n>"] = actions.select_tab,
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
    --- User defined function to transform the paths displayed in the picker.
    ---@param opts table: The opts the users passed into the picker. Might contains a path_display key
    ---@param path string: The path that should be formatted
    ---@return string: The transformed path ready to be displayed
    ---@diagnostic disable-next-line: unused-local
    path_display = function(opts, path)
      local Path = require('plenary.path')
      local utils = require("telescope.utils")
      local tail = utils.path_tail(path)
      local head = Path:new(path):parent():make_relative()
      local short_head = utils.transform_path({ path_display = { 'truncate' } }, head)
      local short_tail = truncate(tail, 20, nil, -1)
      return string.format("%-20s • %s", short_tail, short_head)
    end,
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
    -- winblend = 20,
    preview = { treesitter = { enable = true } },
    -- results_width = 0.8,
    -- borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
    color_devicons = true,
    -- use_less = true,
    set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,
  }
}

require('telescope').load_extension('live_grep_args')
require('telescope').load_extension('git_diffs')
require('telescope').load_extension('lazy')
require('telescope').load_extension('asynctasks')
require('telescope').load_extension('yank_history')
require('telescope').load_extension('refactoring')
require('telescope').load_extension('notify')
