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


    -- file_sorter =  require'telescope.sorters'.get_fuzzy_file,
    -- generic_sorter =  require'telescope.sorters'.get_generic_fuzzy_sorter,
    -- file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    -- grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    -- qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,

    -- Developer configurations: Not meant for general override
    -- buffer_previewer_maker = require'telescope.previewers'.buffer_previewer_maker
  }
}

require('telescope').load_extension('coc')
require('telescope').load_extension('sessions')

local actions = require('telescope.actions')
local trouble = require('trouble.providers.telescope')
local telescope = require('telescope')

require('session_manager').setup {
  sessions_dir = vim.fn.stdpath('data') .. '/sessions', -- The directory where the session files will be saved.
  -- path_replacer = '__', -- The character to which the path separator will be replaced for session files.
  -- colon_replacer = '▏', -- The character to which the colon symbol will be replaced for session files.
  autoload_last_session = false, -- Automatically load last session on startup is started without arguments.
  autosave_last_session = true, -- Automatically save last session on exit.
  -- autosave_ignore_paths = { '~' }, -- Folders to ignore when autosaving a session.
}

telescope.setup {
  defaults = {
    mappings = {
      i = { ["<c-t>"] = trouble.open_with_trouble },
      n = { ["<c-t>"] = trouble.open_with_trouble },
    },
  },
}

-- require('telescope').load_extension('session-lens')
-- require('session-lens').setup {
--     path_display={'shorten'},
-- }
