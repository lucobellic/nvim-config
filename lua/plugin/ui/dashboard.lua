local db = require('dashboard')

db.setup({
    theme = 'hyper',
    config = {
        week_header = {
            enable = true,
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
                action = 'Telescope oldfiles',
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
