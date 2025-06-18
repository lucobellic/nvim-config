return {
  'folke/edgy.nvim',
  opts = {
    left = {
      {
        title = 'dapui_scopes',
        ft = 'dapui_scopes',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        size = { width = 0.2 },
      },
      {
        title = 'dapui_watches',
        ft = 'dapui_watches',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
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
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        size = { width = 0.2 },
      },
      {
        title = 'dapui_breakpoints',
        ft = 'dapui_breakpoints',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
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
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        open = function()
          vim.schedule(function() require('dapui').open() end)
        end,
      },
      { title = 'dapui_console', ft = 'dapui_console' },
    },
  },
}
