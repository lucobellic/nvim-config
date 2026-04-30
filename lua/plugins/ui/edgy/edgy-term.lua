return {
  'folke/edgy.nvim',
  opts = {
    bottom = {
      {
        title = 'terminal',
        ft = 'snacks_terminal',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        open = function()
          -- Don't open a snacks terminal if there are overseer tasks to display
          local ok, task_list = pcall(require, 'overseer.task_list')
          if ok then
            local tasks = task_list.list_tasks({ filter = function(t) return t:get_bufnr() ~= nil end })
            if #tasks > 0 then
              return
            end
          end
          Snacks.terminal.toggle(nil, { win = { position = 'bottom' } })
        end,
      },
      {
        title = 'overseer-tasks',
        ft = 'OverseerOutput',
      },
      {
        title = 'overseer',
        ft = 'OverseerList',
        open = function()
          local overseer_win = require('overseer.window')
          local was_open = overseer_win.is_open()
          vim.cmd('OverseerToggle!')
          -- When opening the panel, also show the most recent task output in the bottom
          if not was_open then
            vim.schedule(function()
              local tasks = require('overseer.task_list').list_tasks({
                filter = function(t) return t:get_bufnr() ~= nil end,
              })
              if #tasks > 0 then
                tasks[1]:open_output('horizontal')
              end
            end)
          end
        end,
        size = { width = 0.15 },
      },
    },
  },
}
