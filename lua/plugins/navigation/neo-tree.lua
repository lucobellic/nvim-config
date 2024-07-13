local components = require('neo-tree.sources.common.components')

local function align(res) return (res and res.text) and res or { text = '  ' } end

local function get_telescope_options(state)
  local node = state.tree:get_node()
  local path = node:get_id()
  -- if path is a file then get the directory
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fn.fnamemodify(path, ':h')
  end
  return { search_dirs = { path } }
end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>e', group = 'explorer' },
      },
    },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    keys = {
      { '<leader>e', false },
      { '<leader>E', false },
      {
        '<leader>ee',
        '<leader>fe',
        desc = 'Explorer NeoTree (root dir)',
        remap = true,
      },
      {
        '<leader>eE',
        '<leader>fE',
        desc = 'Explorer NeoTree (cwd)',
        remap = true,
      },
      {
        '<leader>ef',
        function() require('neo-tree.command').execute({ action = 'focus', source = 'filesystem', reveal = 'true' }) end,
        desc = 'Focus Current File',
        remap = true,
      },
    },
    init = function() vim.g.neo_tree_remove_legacy_commands = 0 end,
    opts = {
      close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
      popup_border_style = vim.g.border.style,

      enable_git_status = true,
      enable_diagnostics = true,
      enable_opened_markers = true,
      enable_modified_markers = true,

      sort_case_insensitive = true, -- used when sorting files and directories in the tree
      sort_function = nil, -- use a custom function for sorting files and directories in the tree
      use_popups_for_input = false, -- use vim.ui.input instead
      show_scrolled_off_parent_node = true,
      auto_clean_after_session_restore = true,
      source_selector = {
        winbar = true, -- toggle to show selector on winbar
        statusline = false, -- toggle to show selector on statusline
        sources = { -- table
          {
            source = 'filesystem', -- string
            display_name = '', -- string | nil
          },
        },
        truncation_character = '', -- string
        tabs_min_width = nil, -- int | nil
        tabs_max_width = nil, -- int | nil
        padding = 0, -- int | { left: int, right: int }
        separator = { left = ' ', right = ' ' }, -- string | { left: string, right: string, override: string | nil }
        separator_active = nil, -- string | { left: string, right: string, override: string | nil } | nil
      },
      default_component_configs = {
        align_diagnostics = {
          symbols = {
            -- hint = '',
            -- info = ' ',
            -- Disable info and hint severity visualizations
            hint = ' ',
            info = '  ',
            warn = ' ',
            error = ' ',
          },
          highlights = {
            hint = 'DiagnosticSignHint',
            info = 'DiagnosticSignInfo',
            warn = 'DiagnosticSignWarn',
            error = 'DiagnosticSignError',
          },
        },
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 1,
          padding = 1, -- extra padding on left hand side
          -- indent guides
          with_markers = false,
          indent_marker = ' ',
          last_indent_marker = ' ',
          highlight = 'NeoTreeIndentMarker',
          -- expander config, needed for nesting files
          with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        icon = {
          folder_closed = ' ',
          folder_open = ' ',
          folder_empty = ' ',
          -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
          -- then these will never be used.
          default = '',
          highlight = 'NeoTreeFileIcon',
        },
        modified = {
          symbol = ' ',
          highlight = 'GitSignsChange',
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = 'NeoTreeFileName',
        },
        align_git_status = {
          symbols = {
            -- Change type
            added = '',
            modified = '',
            deleted = '',
            renamed = '',
            -- Status type
            untracked = '',
            ignored = '',
            unstaged = '',
            staged = '',
            conflict = '',
          },
        },
      },
      window = {
        position = 'left',
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ['/'] = 'none',
          ['<2-LeftMouse>'] = 'open',
          ['<cr>'] = 'open',
          ['l'] = 'open',
          ['<esc>'] = 'revert_preview',
          --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
          ['P'] = { 'toggle_preview', config = { use_float = false } },
          ['S'] = 'open_split',
          ['s'] = 'open_vsplit',
          -- ["S"] = "split_with_window_picker",
          -- ["s"] = "vsplit_with_window_picker",
          ['t'] = 'open_tabnew',
          -- ["<cr>"] = "open_drop",
          -- ["t"] = "open_tab_drop",
          ['w'] = 'open_with_window_picker',
          ['C'] = 'close_node',
          ['h'] = 'close_node',
          ['z'] = 'none',
          -- ["z"] = "close_all_nodes",
          --["Z"] = "expand_all_nodes",
          ['a'] = {
            'add',
            -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = 'none', -- "none", "relative", "absolute"
            },
          },
          ['A'] = 'add_directory', -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
          ['d'] = 'delete',
          ['r'] = 'rename',
          ['y'] = 'copy_to_clipboard',
          ['x'] = 'cut_to_clipboard',
          ['p'] = 'paste_from_clipboard',
          ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like "add":
          -- ["c"] = {
          --  "copy",
          --  config = {
          --    show_path = "none" -- "none", "relative", "absolute"
          --  }
          --}
          ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like "add".
          ['q'] = 'close_window',
          ['<c-q>'] = 'close_window',
          ['R'] = 'refresh',
          ['?'] = 'show_help',
          ['<'] = 'none', -- "prev_source",
          ['>'] = 'none', -- "next_source",
          ['['] = 'prev_source',
          [']'] = 'next_source',
        },
      },
      nesting_rules = {},
      filesystem = {
        bind_to_cwd = true,
        components = {
          align_git_changes = function(config, node, state)
            return { align(components.git_status(config, node, state)[1]) }
          end,
          align_git_status = function(config, node, state)
            return { align(components.git_status(config, node, state)[1]) }
          end,
          align_diagnostics = function(config, node, state) return align(components.diagnostics(config, node, state)) end,
        },
        renderers = {
          directory = {
            {
              'indent',
              with_markers = true,
              indent_size = 2,
              indent_marker = '│',
              last_indent_marker = '╰',
            },
            { 'icon' },
            { 'current_filter' },
            {
              'container',
              width = '100%',
              right_padding = 0,
              content = {
                { 'name', zindex = 10 },
              },
            },
          },
          file = {
            {
              'indent',
              with_markers = true,
              indent_size = 2,
              indent_marker = '│',
              last_indent_marker = '╰',
            },
            { 'icon' },
            {
              'container',
              width = '100%',
              right_padding = 0,
              content = {
                { 'name', zindex = 10 },
                { 'align_diagnostics', zindex = 10, align = 'right' },
                -- {
                --   "align_git_changes",
                --   symbols = {
                --     added    = " ",
                --     deleted  = " ",
                --     modified = " ",
                --     renamed  = " ",
                --   },
                --   zindex = 10,
                --   align = "right"
                -- },
                {
                  'align_git_status',
                  symbols = {
                    untracked = ' ',
                    ignored = ' ',
                    unstaged = ' ',
                    staged = ' ',
                    conflict = ' ',
                  },
                  zindex = 10,
                  align = 'right',
                },
              },
            },
          },
        },
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false, -- only works on Windows for hidden files/directories
          hide_by_name = {
            --"node_modules"
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
        follow_current_file = {
          enabled = true, -- This will find and focus the file in the active buffer every time
          --               -- the current file is changed while the tree is open.
          leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        group_empty_dirs = false, -- when true, empty folders will be grouped together
        hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",  -- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
        window = {
          mappings = {
            ['<C-p>'] = 'telescope_find',
            ['<C-f>'] = 'telescope_grep',
            ['<bs>'] = 'navigate_up',
            ['.'] = 'set_root',
            ['H'] = 'toggle_hidden',
            ['F'] = 'fuzzy_finder',
            ['D'] = 'fuzzy_finder_directory',
            ['f'] = 'filter_on_submit',
            ['<c-x>'] = 'clear_filter',
            ['<g'] = 'prev_git_modified',
            ['<G'] = 'prev_git_modified',
            ['>g'] = 'next_git_modified',
            ['>G'] = 'next_git_modified',
          },
        },
      },
      git_status = {
        window = {
          position = 'float',
          mappings = {
            -- ["A"]  = "git_add_all",
            ['gu'] = 'git_unstage_file',
            ['ga'] = 'git_add_file',
            ['gr'] = 'git_revert_file',
            ['gc'] = 'git_commit',
            ['gp'] = 'git_push',
            ['gg'] = 'git_commit_and_push',
          },
        },
      },
      commands = {
        telescope_find = function(state) require('telescope.builtin').find_files(get_telescope_options(state)) end,
        telescope_grep = function(state) require('telescope.builtin').live_grep(get_telescope_options(state)) end,
      },
    },
  },
}
