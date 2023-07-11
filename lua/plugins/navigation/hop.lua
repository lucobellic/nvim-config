return {
  'phaazon/hop.nvim',
  event = 'VeryLazy',
  enabled = false,
  branch = 'v2',
  keys = {
    {
      '<leader>j',
      "<cmd>lua require'hop'.hint_words()<cr>",
      mode = { 'n', 'v' },
      desc =
      'Hop words'
    },
    {
      '<leader>J',
      "<cmd>lua require'hop'.hint_words({multi_windows = true})<cr>",
      mode = { 'n', 'v' },
      desc =
      'Hop all words'
    },
    {
      '<leader>l',
      "<cmd>lua require'hop'.hint_lines()<cr>",
      mode = { 'n', 'v' },
      desc =
      'Hop lines'
    },
    {
      '<leader>L',
      "<cmd>lua require'hop'.hint_lines({multi_windows = true})<cr>",
      mode = { 'n', 'v' },
      desc =
      'Hop all lines'
    },
    {
      '<leader>k',
      "<cmd>lua require'hop'.hint_char2()<cr>",
      mode = { 'n', 'v' },
      desc =
      'Hop patterns'
    },
    {
      '<leader>K',
      "<cmd>lua require'hop'.hint_char2hint_patterns({multi_windows = true})<cr>",
      mode = { 'n', 'v' },
      desc =
      'Hop all patterns'
    },
  },
  opts = {
    case_insensitive = true,
    winblend = 50,
    teasing = true
  }
}
