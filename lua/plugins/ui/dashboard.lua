local db = require('dashboard')

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

db.setup({
  theme = 'hyper',
  preview = {
    command = 'cat | lolcat -F 0.3',
    file_path = vim.fn.stdpath("config") .. '/lua/plugins/ui/header.cat',
    file_width = 69,
    file_height = 10,
  },
  config = {
    week_header = {
      enable = false,
    },
    shortcut = {
      {
        desc = ' Update',
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
        action = 'SessionManager load_session',
        key = 's',
      },
      {
        desc = ' Recent',
        group = 'Number',
        action = 'Telescope oldiles',
        key = 'r',
      },
    },
  },
})


-- Command
vim.cmd [[
    nmap <leader>xs :<C-u>SessionManager save_current_session<cr>
    nmap <leader>fs :<C-u>SessionManager load_session<cr>
]]
