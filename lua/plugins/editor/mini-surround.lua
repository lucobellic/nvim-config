return {
  'echasnovski/mini.surround',
  event = 'VeryLazy',
  keys = {
    {
      'S',
      ":<c-u>lua require('mini.surround').add('visual')<cr>",
      mode = { 'v' },
      silent = true,
      desc = 'Surround',
    },
  },
  opts = {},
}
