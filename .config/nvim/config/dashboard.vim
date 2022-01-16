let g:dashboard_default_executive = 'telescope'
let g:dashboard_session_directory = 'C:\Users\uib97373\.cache\vim\session'
let g:autoload_last_session = v:false
let g:autosave_last_session = v:true

" https://github.com/glepnir/dashboard-nvim/wiki/Ascii-Header-Text
let g:dashboard_custom_header = [
\ ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
\ ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
\ ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
\ ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
\ ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
\ ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
\]

nmap <leader>xs :<C-u>SessionManager save_current_session<cr>
nmap <leader>fs :<C-u>SessionManager load_session<cr>

let g:dashboard_custom_shortcut = {
\ 'last_session'       : 'SPC f s',
\ 'find_history'       : 'SPC f r',
\ 'find_file'          : 'SPC f f',
\ 'new_file'           : 'SPC c n',
\ 'change_colorscheme' : 'SPC t c',
\ 'find_word'          : 'SPC f w',
\ 'book_marks'         : 'SPC f m',
\ }
