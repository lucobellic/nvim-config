local db = require('dashboard')
local persistence_config = require('persistence.config')

local banner = {
  "",
  "",
  "                                                                   ",
  "      ███████████           █████      ██                    ",
  "     ███████████             █████                            ",
  "     ████████████████ ███████████ ███   ███████    ",
  "    ████████████████ ████████████ █████ ██████████████  ",
  "   █████████████████████████████ █████ █████ ████ █████  ",
  " ██████████████████████████████████ █████ █████ ████ █████ ",
  "██████  ███ █████████████████ ████ █████ █████ ████ ██████",
  "██████   ██  ███████████████   ██ █████████████████",
  "██████   ██  ███████████████   ██ █████████████████",
  "                                                                     ",
  "",
}

local function load_session(path)
  local pattern = "/"
  if vim.fn.has("win32") == 1 then
    pattern = "[\\:]"
  end
  local name = path:gsub(pattern, "%%")
  local session = persistence_config.options.dir .. name .. ".vim"
  if session and vim.fn.filereadable(session) ~= 0 then
    vim.cmd("silent! source " .. vim.fn.fnameescape(session))
  end
end

db.setup({
  theme = 'hyper',
  preview = {
    command = 'cat | lolcat -F 0.3',
    file_path = vim.fn.stdpath("config") .. '/lua/plugins/ui/header.cat',
    file_width = 70,
    file_height = 10,
  },
  config = {
    week_header = {
      enable = false,
    },
    project = {
      enable = true,
      limit = 10,
      icon = '󰏓 ',
      label = 'Recent Projects:',
      action = load_session,
    },
    shortcut = {
      {
        desc = '󰊳 Update',
        group = '@property',
        action = 'Lazy update',
        key = 'u'
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
    },
  },
})
