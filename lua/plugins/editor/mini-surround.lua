return {
  'echasnovski/mini.surround',
  keys = {
    {'S', ":<c-u>lua MiniSurround.add('visual')<cr>",  mode = {'v'}, silent = true, desc = 'Surround'}
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
