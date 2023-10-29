-- Setup command line palette with wilder.nvim
local cmdline = {
  enabled = true,
  view = 'cmdline_popup',
  opts = {},
  format = {
    cmdline = { pattern = '^:', icon = ' ', title = ' Command ', lang = 'vim' },
    search_down = { kind = 'search', pattern = '^/', icon = '  ', lang = 'regex' },
    search_up = { kind = 'search', pattern = '^%?', icon = '  ', lang = 'regex' },
    replace = { pattern = { '^:%s*s/', '^:%s*%%s/' }, icon = ' ', lang = 'regex' },
    range_replace = { pattern = "^:%s*'<,'>s/", icon = '  ', title = ' Range Replace ', lang = 'regex' },
    range = { pattern = "^:%s*'<,'>", icon = '  ', lang = 'regex' },
    shell = { pattern = '^:%s*!', icon = ' ', lang = 'bash' },
    lua = { pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' }, icon = '', lang = 'lua' },
    help = { pattern = '^:%s*he?l?p?%s+', icon = ' ' },
    file = { pattern = '^:%s*e', icon = ' ' },
  },
}

local cmdline_popup_view = {
  position = {
    row = 3,
    col = '50%',
  },
  size = {
    width = '28%',
    height = 'auto',
  },
  border = {
    style = 'rounded',
    padding = { 0, 1 },
  },
  filter_options = {},
}

local views = {
  cmdline_popup = cmdline_popup_view,
  mini = {
    position = { row = -1, col = 0 },
    size = {
      width = '20%',
      height = 3,
      align = 'message-left',
    },
    reverse = true,
  },
  notify = {
    replace = true,
    merge = false,
  },
}

local lsp = {
  -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
  override = {
    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
    ['vim.lsp.util.stylize_markdown'] = true,
    ['cmp.entry.get_documentation'] = true,
  },
  progress = {
    enabled = false,
  },
  message = {
    enabled = true,
    view = 'notify',
  },
  hover = {
    enabled = true,
  },
  signature = {
    enabled = true,
  },
}

local filter_skip = {
  filter = {
    any = {
      -- Hide display messages but still show them in :messages
      { event = 'msg_show', kind = { '', 'echo', 'echomsg', 'search_count' }, find = 'written' },
      { event = 'msg_show', kind = { '', 'echo', 'echomsg', 'search_count' }, find = 'yanked' },
      { event = 'msg_show', kind = 'wmsg', find = 'BOTTOM' },
      { event = 'notify', kind = 'error', find = 'Neo' },
      { event = 'msg_show', kind = 'emsg', find = 'Pattern not found' },
      { event = 'msg_show', kind = 'lua_error', find = 'bdelete' },
      { event = 'msg_show', kind = 'lua_error', find = 'inlay_hint' },
      { event = 'msg_show', kind = '', find = 'lnum' },
      { event = 'notify', kind = 'warn', find = 'Unsupported input type' },
      { event = 'msg_show', kind = '', find = 'query' },
      { event = 'msg_show', kind = 'lua_error', find = 'Autocommands' },
      -- Hide spamming pylsp messages
      { event = 'lsp', find = 'pylsp' },
      -- Hide spamming cspell messages
      { event = 'lsp', find = 'cspell' },
      -- Hide spamming null-ls messages
      { event = 'lsp', find = 'diagnostics' },
    },
  },
  opts = { stop = true, skip = true },
}

local spinners = require('noice.util.spinners').spinners

-- Custom spinners
-- add programming font progress bar and spinner
-- such as fira code https://github.com/tonsky/FiraCode#whats-in-the-box
spinners.font_progress_bar = {
  frames = {
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
  },
  interval = 100,
}

spinners.font_spinner = {
  frames = { '', '', '', '', '', '' },
  interval = 100,
}

return {
  'folke/noice.nvim',
  keys = {
    { '<c-f>', false },
    { '<c-p>', false },
    {
      '<leader>snn',
      function()
        require('telescope').extensions.notify.notify()
      end,
      desc = 'Find Notifications',
    },
  },
  opts = {
    cmdline = cmdline,
    lsp = lsp,

    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = { enabled = false }, -- use a classic bottom cmdline for search
      command_palette = { enabled = false }, -- position the cmdline and popupmenu together
      long_message_to_split = { enabled = false }, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    views = views,
    routes = { filter_skip },
    messages = {
      enabled = true, -- enables the Noice messages UI
      view = 'notify', -- default view for messages
      view_error = 'notify', -- view for errors
      view_warn = 'notify', -- view for warnings
      view_history = 'messages', -- view for :messages
      view_search = false, -- view for search count messages. Set to `false` to disable
    },
    notify = {
      enabled = true,
      view = 'notify',
    },
    format = {
      spinner = {
        name = 'growHorizontal',
      },
    },
    commands = {
      history = {
        view = 'split',
        opts = { enter = true, format = 'details' },
        filter = {},
      },
    },
  },
}
