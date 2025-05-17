return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>r', group = 'refactor' },
        { '<leader>rb', group = 'block' },
      },
    },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    cmd = { 'Refactor' },
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    keys = {
      {
        '<leader>re',
        function() return require('refactoring').refactor('Extract Function') end,
        mode = 'v',
        desc = 'Extract Function',
        expr = true,
      },
      {
        '<leader>rf',
        function() return require('refactoring').refactor('Extract Function To File') end,
        mode = 'v',
        desc = 'Extract Function To File',
        expr = true,
      },
      {
        '<leader>rv',
        function() return require('refactoring').refactor('Extract Variable') end,
        mode = 'v',
        desc = 'Extract Variable',
        expr = true,
      },
      {
        '<leader>ri',
        function() return require('refactoring').refactor('Inline Variable') end,
        mode = 'v',
        desc = 'Inline Variable',
        expr = true,
      },
      -- prompt for a refactor to apply when the remap is triggered
      {
        '<leader>rs',
        function() require('refactoring').select_refactor({}) end,
        mode = 'v',
        desc = 'Select Refactor',
      },
      -- remap to open the Telescope refactoring menu in visual mode
      {
        '<leader>rt',
        function() require('telescope').extensions.refactoring.refactors() end,
        mode = 'v',
        desc = 'Telescope Refactor',
      },

      -- Extract block doesn't need visual mode
      {
        '<leader>rbb',
        function() return require('refactoring').refactor('Extract Block') end,
        desc = 'Extract Block',
        expr = true,
      },
      {
        '<leader>rbf',
        function() return require('refactoring').refactor('Extract Block To File') end,
        desc = 'Extract Block To File',
        expr = true,
      },
      -- Inline variable can also pick up the identifier currently under the cursor without visual mode
      {
        '<leader>ri',
        function() return require('refactoring').refactor('Inline Variable') end,
        desc = 'Inline Variable',
        expr = true,
      },
    },
  },
}
