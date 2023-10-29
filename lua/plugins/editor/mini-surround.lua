return {
  'echasnovski/mini.surround',
  keys = {
    {
      'S',
      ":<c-u>lua require('mini.surround').add('visual')<cr>",
      mode = { 'v' },
      silent = true,
      desc = 'Surround',
    },
  },
  opts = {
    mappings = {
      add = 'csa',
      delete = 'csd',
      find = 'csf',
      find_left = 'csF',
      highlight = 'csh',
      replace = 'csr',
      update_n_lines = 'csn',
    },
  },
}
