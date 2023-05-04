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

  -- Tests
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
  },

  -- Coverage
  {
    'andythigpen/nvim-coverage',
    dependencies = 'nvim-lua/plenary.nvim',
    -- Optional: needed for PHP when using the cobertura parser
    -- rocks = { 'lua-xmlreader' },
    config = function()
      require("coverage").setup({
        lang = {
          cpp = {
            coverage_file = "./.coverage/lcov.info"
          }
        }
      })
    end,
  }
}
