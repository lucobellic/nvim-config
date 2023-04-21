return {
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-nvim-dap').setup({ ensure_installed = { 'python', 'cppdbg' } })
    end
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      require("dapui").setup()
    end
  },
}
