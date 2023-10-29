return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>r'] = { name = '+refactor' },
        ['<leader>rb'] = { name = '+block' },
      },
    },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    keys = {
      {
        '<leader>re',
        function()
          require('refactoring').refactor('Extract Function')
        end,
        mode = 'v',
        desc = 'Extract Function',
      },
      {
        '<leader>rf',
        function()
          require('refactoring').refactor('Extract Function To File')
        end,
        mode = 'v',
        desc = 'Extract Function To File',
      },
      {
        '<leader>rv',
        function()
          require('refactoring').refactor('Extract Variable')
        end,
        mode = 'v',
        desc = 'Extract Variable',
      },
      {
        '<leader>ri',
        function()
          require('refactoring').refactor('Inline Variable')
        end,
        mode = 'v',
        desc = 'Inline Variable',
      },
      -- prompt for a refactor to apply when the remap is triggered
      {
        '<leader>rr',
        function()
          require('refactoring').select_refactor({})
        end,
        mode = 'v',
        desc = 'Select Refactor',
      },
      -- remap to open the Telescope refactoring menu in visual mode
      {
        '<leader>rt',
        function()
          require('telescope').extensions.refactoring.refactors()
        end,
        mode = 'v',
        desc = 'Telescope Refactor',
      },

      -- Extract block doesn't need visual mode
      {
        '<leader>rbb',
        function()
          require('refactoring').refactor('Extract Block')
        end,
        desc = 'Extract Block',
      },
      {
        '<leader>rbf',
        function()
          require('refactoring').refactor('Extract Block To File')
        end,
        desc = 'Extract Block To File',
      },
      -- Inline variable can also pick up the identifier currently under the cursor without visual mode
      {
        '<leader>ri',
        function()
          require('refactoring').refactor('Inline Variable')
        end,
        desc = 'Inline Variable',
      },
    },
  },
}
