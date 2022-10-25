local db = require('dashboard')

-- type can be nil,table or function(must be return table in function)
-- if not config will use default banner
db.custom_header = {
    ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
    ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
    ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
    ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
    ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
    ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
    '                                                       '
}

-- table type and in this table you can set icon,desc,shortcut,action keywords. desc must be exist and type is string
-- icon type is nil or string
-- shortcut type is nil or string also like icon
-- action type can be string or function or nil.
-- if you don't need any one of icon shortcut action ,you can ignore it.
db.custom_center = { { desc = 'Here start the end' } }

-- db.custom_footer  -- type can be nil,table or function(must be return table in function)
-- db.preview_file_Path    -- string or function type that mean in function you can dynamic generate height width
-- db.preview_file_width   -- number type
-- db.preview_command      -- string type
-- db.hide_statusline      -- boolean default is true.it will hide statusline in dashboard buffer and auto open in other buffer
-- db.hide_tabline         -- boolean default is true.it will hide tabline in dashboard buffer and auto open in other buffer

-- TODO: Set portable path
db.session_directory = 'C:/Users/uib97373/.cache/vim/session' -- string type the directory to store the session file

db.preview_file_height = 12 -- number type
db.header_pad          = 5 -- number type default is 1
db.center_pad          = 5 -- number type default is 1
db.footer_pad          = 5 -- number type default is 1

-- example of db.custom_center for new lua coder,the value of nil mean if you
-- don't need this filed you can not write it
-- db.custom_center = {
--   { icon = 'some icon' desc = 'some description here' } --correct if you don't action filed
--   { desc = 'some description here' }                    --correct if you don't action and icon filed
--   { desc = 'some description here' action = 'Telescope find files'} --correct if you don't icon filed
-- }
--
db.custom_center = {
    { icon = '  ',
        desc = 'Find session                            ',
        shortcut = 'SPC f s' },
    { icon = '  ',
        desc = 'Recently opened files                   ',
        shortcut = 'SPC f r' },
    { icon = '  ',
        desc = 'Find File                               ',
        shortcut = 'SPC f f' },
}

-- Highlight Group
-- DashboardHeader DashboardCenter DashboardCenterIcon DashboardShortCut DashboardFooter

-- Command
vim.cmd [[
    nmap <leader>xs :<C-u>SessionManager save_current_session<cr>
    nmap <leader>fs :<C-u>SessionManager load_session<cr>
]]

-- DashboardNewFile  -- if you like use `enew` to create file,Please use this command,it's wrap enew and restore the statsuline and tabline
-- SessionSave,SessionLoad
