-- local theme = 'doom'
local theme = 'hyper'
local doom_shortcut = {
  {
    icon = '󰊳 ',
    icon_hl = '@property',
    desc = 'Update',
    desc_hl = '@property',
    group = '@property',
    action = 'Lazy update',
    key = 'u',
    key_hl = '@property',
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
  'nvimdev/dashboard-nvim',
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
        command = 'cat | lolcat -F 0.3',
        file_path = vim.fn.stdpath('config') .. '/lua/plugins/ui/header.cat',
        file_width = 72,
        file_height = 12,
      },
      config = configs[theme],
    })
  end,
}
