require('lspsaga').setup({
    diagnostic = {
        on_insert = false,
    },
    lightbulb = { enable = false },
    outline = {
        auto_preview = false,
        keys = {
            jump = '<Enter>',
            expand_collapse = nil
        }
    },
    symbol_in_winbar = {
        enable = true,
        separator = ' > ',
        show_file = true,
    },
    rename = {
        in_select = false
    },
    ui = {
        theme = 'round',
        border = 'rounded',
        winblend = 0,
        colors = {
            --float window normal bakcground color
            normal_bg = '#0B0E14',
            --title background color
            title_bg = '#0D1017',
        }
    },
    code_action = {
        num_shortcut = true
    }
})
