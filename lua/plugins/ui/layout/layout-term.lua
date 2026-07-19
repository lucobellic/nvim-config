local function not_floating(_, win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function ft_and(ft, fn)
  return function(buf, win) return vim.bo[buf].filetype == ft and fn(buf, win) end
end

return {
  'lucobellic/layout.nvim',
  opts = {
    bottom = {
      {
        name = 'terminal',
        picker = { icon = '', key = '`' },
        views = {
          {
            name = 'snacks',
            filter = ft_and('snacks_terminal', not_floating),
            open = function() Snacks.terminal.toggle(nil, { win = { position = 'bottom', height = 10 } }) end,
          },
        },
      },
      {
        name = 'overseer',
        picker = { icon = '', key = 'p' },
        views = {
          {
            name = 'overseer_tasks',
            filter = ft_and('OverseerOutput', not_floating),
          },
          {
            name = 'overseer',
            filter = ft_and('OverseerList', not_floating),
            open = function()
              local overseer_win = require('overseer.window')
              local is_open = overseer_win.is_open()
              local tasks = require('overseer.task_list').list_tasks({
                filter = function(t) return t:get_bufnr() ~= nil end,
              })
              local has_tasks = tasks and #tasks > 0

              if not is_open and has_tasks then
                overseer_win.open()
                vim.schedule(function()
                  vim.iter(tasks):each(function(task) task:open_output('horizontal') end)
                end)
              else
                overseer_win.close()
              end
            end,
            size = 25,
          },
        },
      },
    },
  },
}
