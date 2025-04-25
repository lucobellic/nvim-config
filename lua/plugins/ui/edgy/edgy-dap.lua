return {
  'folke/edgy.nvim',
  opts = {
    left = {
      { title = 'dapui_scopes', ft = 'dapui_scopes', size = { width = 0.2 } },
      {
        title = 'dapui_watches',
        ft = 'dapui_watches',
        size = { width = 0.2 },
        open = function()
          vim.schedule(function() require('dapui').open() end)
        end,
      },
    },
    right = {
      {
        title = 'dapui_stacks',
        ft = 'dapui_stacks',
        size = { width = 0.2 },
      },
      {
        title = 'dapui_breakpoints',
        ft = 'dapui_breakpoints',
        size = { width = 0.2 },
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
