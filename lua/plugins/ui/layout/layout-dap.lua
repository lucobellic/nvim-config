local function not_floating(_, win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function ft_and(ft, fn)
  return function(buf, win) return vim.bo[buf].filetype == ft and fn(buf, win) end
end

return {
  'lucobellic/layout.nvim',
  opts = {
    left = {
      {
        name = 'dap-left',
        picker = { icon = '', key = 'd' },
        views = {
          {
            name = 'dapui_scopes',
            filter = ft_and('dapui_scopes', not_floating),
          },
          {
            name = 'dapui_watches',
            filter = ft_and('dapui_watches', not_floating),
            open = function()
              vim.schedule(function() require('dapui').open() end)
            end,
          },
        },
      },
    },
    right = {
      {
        name = 'dap-right',
        picker = { icon = '', key = 'd' },
        views = {
          {
            name = 'dapui_stacks',
            filter = ft_and('dapui_stacks', not_floating),
          },
          {
            name = 'dapui_breakpoints',
            filter = ft_and('dapui_breakpoints', not_floating),
            open = function()
              vim.schedule(function() require('dapui').open() end)
            end,
          },
        },
      },
    },
    bottom = {
      {
        name = 'dap-bottom',
        picker = { icon = '', key = 'd' },
        views = {
          {
            name = 'repl',
            filter = ft_and('dap-repl', not_floating),
            open = function()
              vim.schedule(function() require('dapui').open() end)
            end,
          },
          {
            name = 'console',
            filter = 'dapui_console',
          },
        },
      },
    },
  },
}
