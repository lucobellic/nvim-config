return {
  'petertriho/nvim-scrollbar',
  event = 'BufEnter',
  dependencies = {
    'lewis6991/gitsigns.nvim',
    {
      'kevinhwang91/nvim-hlslens',
      opts = {
        override_lens = function() end,
        build_position_cb = function(plist, _, _, _)
          require('scrollbar.handlers.search').handler.show(plist.start_pos)
        end,
      }
    }
  },
  opts = {
    show = true,
    show_in_active_only = true,
    set_highlights = true,
    handle = {
      text = ' ',
      hide_if_all_visible = true
    },
    marks = {
      Cursor = {
        text = '', -- ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ ┨ ┩ ┪ ┫ ┼ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋
        priority = 0,
      },
      Search = {
        text = { '─', '─' },
        priority = 1,
      },
      Error = {
        text = { '│', '│' },
        priority = 2,
      },
      Warn = {
        text = { '│', '│' },
        priority = 3,
      },
      Info = {
        text = { ' ', ' ' },
        priority = 10,
      },
      Hint = {
        text = { ' ', ' ' },
        priority = 10,
      },
      Misc = {
        text = { ' ', ' ' },
        priority = 10,
      },
      GitAdd = {
        text = { '│', '│' },
        priority = 5,
      },
      GitDelete = {
        text = { '│', '│' },
        priority = 5,
      },
      GitChange = {
        text = { '│', '│' },
        priority = 5,
      },
    },
    excluded_buftypes = {
      -- 'terminal',
    },
    excluded_filetypes = {
      '',
      'Navbuddy',
      'Outline',
      'TelescopePrompt',
      'chatgpt',
      'cmp_docs',
      'cmp_menu',
      'dap-repl',
      'dapui_breakpoints',
      'dapui_console',
      'dapui_scopes',
      'dapui_stacks',
      'dapui_watches',
      'dashboard',
      'floaterm',
      'toggleterm',
      'incline',
      'neo-tree',
      'notify',
      'prompt',
    },
    handlers = {
      cursor = true,
      diagnostic = true,
      gitsigns = false,
      handle = true,
      search = true,
      ale = false,
    }
  },
  config = function(_, opts)
    -- Provide full control over highlights
    ---@diagnostic disable-next-line: duplicate-set-field
    require('scrollbar.utils').set_highlights = function() end
    require('scrollbar').setup(opts)

    local gitsign = require('gitsigns')
    local gitsign_hunks = require('gitsigns.hunks')

    local colors_type = {
      add = 'GitAdd',
      delete = 'GitDelete',
      change = 'GitChange',
      changedelete = 'GitChange'
    }

    local function get_gitsign_lines(bufnr, nb_lines)
      local lines = {}
      local hunks = gitsign.get_hunks(bufnr)

      for _, hunk in ipairs(hunks or {}) do
        hunk.vend = math.min(hunk.added.start, hunk.removed.start) + hunk.added.count + hunk.removed.count
        local signs = gitsign_hunks.calc_signs(hunk, 0, nb_lines, false)
        for _, sign in ipairs(signs) do
          table.insert(lines, {
            line = sign.lnum,
            type = colors_type[sign.type]
          })
        end
      end
      return lines
    end

    local function add_git_signs(bufnr)
      local nb_lines = vim.api.nvim_buf_line_count(bufnr)
      return get_gitsign_lines(bufnr, nb_lines)
    end

    require('scrollbar.handlers').register('git', add_git_signs)

    -- Hide search scrollbar when leaving search mode
    vim.api.nvim_create_autocmd({ 'CmdlineLeave' }, {
      pattern = { '*' },
      callback = function()
        require('scrollbar.handlers.search').handler.hide()
      end
    })
  end
}
