return {
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = { 'python', 'cppdbg' }
    }
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'rouge8/neotest-rust',
      'nvim-neotest/neotest-plenary',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-vim-test'
    },
    -- opts = require('plugins.dap.neotest')
  }
}
