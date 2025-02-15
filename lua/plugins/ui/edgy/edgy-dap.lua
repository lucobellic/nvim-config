return {
  'folke/edgy.nvim',
  opts = {
    left = {
      { title = 'dapui_scopes', ft = 'dapui_scopes' },
      {
        title = 'dapui_watches',
        ft = 'dapui_watches',
        open = function()
          vim.schedule(function() require('dapui').open() end)
        end,
      },
    },
    right = {
      { title = 'dapui_stacks', ft = 'dapui_stacks' },
      {
        title = 'dapui_breakpoints',
        ft = 'dapui_breakpoints',
        open = function()
          vim.schedule(function() require('dapui').open() end)
        end,
      },
    },
    bottom = {
      {
        title = 'dap-repl',
        ft = 'dap-repl',
        open = function()
          vim.schedule(function() require('dapui').open() end)
        end,
      },
      { title = 'dapui_console', ft = 'dapui_console' },
    },
  },
}
