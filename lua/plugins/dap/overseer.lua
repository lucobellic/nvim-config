vim.api.nvim_create_user_command("OverseerRestartLast", function()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN, { title = "Overseer" })
  else
    overseer.run_action(tasks[1], "restart")
  end
end, {})

return {
  'stevearc/overseer.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>xr', ':OverseerRun<cr>',    desc = 'Overseer Run' },
    { '<leader>xi', ':OverseerInfo<cr>',   desc = 'Overseer Info' },
    { '<leader>xo', ':OverseerToggle<cr>', desc = 'Overseer Toggle' },
  },
  opts = {
    strategy = {
      'toggleterm',
      open_on_start = false,
      close_on_exit = false,
      hidden = false,
      quit_on_exit = "never",
    },
    task_list = {
      direction = 'right',
    },
    form = {
      win_opts = {
        winblend = vim.o.pumblend,
      },
    }
  },
}
