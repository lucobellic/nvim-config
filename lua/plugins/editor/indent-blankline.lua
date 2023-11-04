local highlight = {
  'TSRainbowYellow',
  'TSRainbowViolet',
  'TSRainbowBlue',
  'TSRainbowOrange',
  'TSRainbowGreen',
  'TSRainbowViolet',
  'TSRainbowCyan',
  'TSRainbowRed',
}

return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  opts = {
    indent = {
      char = '│',
      tab_char = '│',
      highlight = 'IndentBlankLineChar',
    },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
      injected_languages = false,
      highlight = highlight,
      include = {
        node_type = {
          lua = { 'return_statement', 'table_constructor' },
          python = { 'if_statement', 'for_statement', 'while_statement', 'with_statement' },
        },
        -- Make every node type valid. Note that this can lead to some weird behavior
        -- node_type = { ["*"] = { "*" } },
      },
    },
  },
}
