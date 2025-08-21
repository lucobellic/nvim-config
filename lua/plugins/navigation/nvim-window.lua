return {
  'yorickpeterse/nvim-window',
  keys = {
    { '<leader>k', "<cmd>lua require('nvim-window').pick()<cr>", desc = 'Jump To Window' },
  },
  opts = {
    -- A group to use for overwriting the Normal highlight group in the floating
    -- window. This can be used to change the background color.
    normal_hl = 'Normal',

    -- The highlight group to apply to the line that contains the hint characters.
    -- This is used to make them stand out more.
    hint_hl = 'FloatTitle',

    -- The border style to use for the floating window.
    border = vim.g.border_style,

    -- The characters available for hinting windows.
    chars = {
      'a',
      's',
      'd',
      'f',
      'g',
      'h',
      'j',
      'k',
      'l',
      ';',
      'q',
      'w',
      'e',
      'r',
      't',
      'y',
      'u',
      'i',
      'o',
      'p',
      'z',
      'x',
      'c',
      'v',
      'b',
      'n',
      'm',
      ',',
    },
  },
}
