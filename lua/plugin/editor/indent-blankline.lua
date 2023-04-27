require("indent_blankline").setup {
    -- for example, context is off by default, use this to turn it on
    show_current_context = false,
    show_current_context_start = false,
    space_char_blankline = " ",
    char = "▏",
    show_first_indent_level = true,
    show_trailing_blankline_indent = false,
    filetype_exclude = {
        "dashboard",
        "lspinfo",
        "packer",
        "checkhealth",
        "help",
        "man",
        "",
    }
}

