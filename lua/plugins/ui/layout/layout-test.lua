local function not_floating(_, win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function ft_and(ft, fn)
  return function(buf, win) return vim.bo[buf].filetype == ft and fn(buf, win) end
end

return {
  'lucobellic/layout.nvim',
  opts = {
    right = {
      {
        name = 'test',
        picker = { icon = '', key = 't' },
        views = {
          {
            name = 'neotest-summary',
            filter = ft_and('neotest-summary', not_floating),
            open = 'Neotest summary',
            events = { 'WinEnter', 'BufWinEnter' },
          },
        },
      },
    },
    bottom = {
      {
        name = 'test',
        picker = { icon = '', key = 'T' },
        views = {
          {
            name = 'neotest-panel',
            filter = ft_and('neotest-output-panel', not_floating),
            open = 'Neotest output-panel',
            events = { 'WinEnter', 'BufWinEnter' },
          },
        },
      },
    },
  },
}
