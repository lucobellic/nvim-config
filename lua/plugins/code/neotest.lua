return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/neotest-plenary',
    'nvim-neotest/neotest-vim-test'
  },
  opts = {
    adapters = {
      'neotest-plenary',
      'neotest-vim-test',
    }
  },
}
