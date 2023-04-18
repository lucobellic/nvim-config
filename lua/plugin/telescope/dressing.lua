require('dressing').setup({
  input = {
    -- Default prompt string
    default_prompt = "➤ ",

    -- When true, <Esc> will close the modal
    insert_only = true,

    -- These are passed to nvim_open_win
    anchor = "SW",
    relative = "cursor",
    border = "rounded",

    -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
    prefer_width = 40,
    max_width = nil,
    min_width = 20,

    -- Window transparency (0-100)
    win_option = {
      -- winblend = 20,
      -- Change default highlight groups (see :help winhl)
      winhighlight = "",
    },

    -- see :help dressing_get_config
    get_config = nil,
  },
  select = {
    -- Priority list of preferred vim.select implementations
    backend = { "telescope" },

    -- Options for telescope selector
    telescope = {
      -- can be 'dropdown', 'cursor', or 'ivy'
      vimgrep_arguments = {
        'rg',
        '--color=never',
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
      -- winblend = 20,
      previewer = false,
      -- results_width = 0.8,
      borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
      color_devicons = true,
      -- use_less = true,
      set_env = { ['COLORTERM'] = 'truecolor' }, -- default = nil,

    },

    -- Used to override format_item. See :help dressing-format
    format_item_override = {},

    -- see :help dressing_get_config
    get_config = nil,
  },
})
