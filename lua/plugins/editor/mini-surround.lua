return {
  'echasnovski/mini.surround',
  keys = {
    {'S', ":<c-u>lua MiniSurround.add('visual')<cr>",  mode = {'v'}, silent = true, desc = 'Surround'}
  },
  opts = {
    mappings = {
      add = 'sa',
      delete = 'sd',
      find = 'sf',
      find_left = 'sF',
      highlight = 'sh',
      replace = 'sr',
      update_n_lines = 'sn',
    },
  },
}
