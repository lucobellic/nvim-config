-- local theme = 'doom'
local theme = 'hyper'
local doom_shortcut = {
  {
    desc = ' Update',
    group = 'Label',
    action = 'Lazy update',
    key = 'u',
  },
  {
    desc = ' Sessions',
    group = '@property',
    action = 'PersistenceLoadSession',
    key = 's',
  },
  {
    desc = ' Last Session',
    group = 'Number',
    action = 'PersistenceLoadLast',
    key = 'l',
  },
  {
    desc = ' Files',
    group = 'DiagnosticInfo',
    action = 'Telescope find_files',
    key = 'f',
  },
  {
    desc = ' Recent',
    group = '@string',
    action = 'Telescope oldfiles',
    key = 'r',
  },
}

local shortcut = {
  {
    desc = '󰊳 Update',
    group = '@property',
    action = 'Lazy update',
    key = 'u',
  },
  {
    desc = ' Files',
    group = 'Label',
    action = 'Telescope find_files',
    key = 'f',
  },
  {
    desc = ' Sessions',
    group = 'DiagnosticHint',
    action = 'PersistenceLoadSession',
    key = 's',
  },
  {
    desc = ' Recent',
    group = 'Number',
    action = 'Telescope oldfiles',
    key = 'r',
  },
}

return {
  'lucobellic/dashboard-nvim',
  enabled = false,
  -- enabled = not (vim.g.started_by_firenvim or vim.env.KITTY_SCROLLBACK_NVIM == 'true'),
  event = 'UIEnter',
  opts = function(_, opts)
    local function load_session(path)
      local pattern = '/'
      if vim.fn.has('win32') == 1 then
        pattern = '[\\:]'
      end
      local name = path:gsub(pattern, '%%')
      local session = require('persistence.config').options.dir .. name .. '.vim'
      require('util.persistence').load_session(session)
    end

    local configs = {
      hyper = {
        week_header = {
          enable = false,
        },
        project = {
          enable = true,
          limit = 10,
          icon = '󰏓',
          label = '  Recent Projects:',
          action = load_session,
        },
        shortcut = doom_shortcut,
        footer = {},
      },
      doom = {
        -- header = {},
        center = doom_shortcut,
        -- footer = {},
      },
    }

    return vim.tbl_extend('force', opts, {
      theme = theme,
      hide = {
        statusline = true,
        tabline = true,
        winbar = true,
      },
      preview = {
        command = 'cat | cat',
        file_path = vim.fn.stdpath('config') .. '/lua/plugins/ui/header.cat',
        file_width = 72,
        file_height = 11,
      },
      config = configs[theme],
    })
  end,
}
