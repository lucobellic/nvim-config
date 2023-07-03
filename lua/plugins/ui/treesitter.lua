return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = { 'HiPhish/nvim-ts-rainbow2' },
  opts = {
    ensure_installed = {
      'cmake',
      'python',
      'yaml',
      'json',
      'vim',
      'markdown',
      'markdown_inline',
    },
    highlight = {
      enable = true,
      disable = { 'c', 'cpp', 'rust', 'lua' }, -- disable highlight supported by lsp
      custom_captures = {
        -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
        -- ["foo.bar"] = "Constant",
      },
    },
    rainbow = {
      enable = true,
      hlgroups = {
        'TSRainbowYellow',
        'TSRainbowViolet',
        'TSRainbowBlue',
        'TSRainbowOrange',
        'TSRainbowGreen',
        'TSRainbowViolet',
        'TSRainbowCyan',
        'TSRainbowRed',
      },
    }
  }
}
