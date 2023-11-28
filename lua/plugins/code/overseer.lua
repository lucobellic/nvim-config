vim.api.nvim_create_user_command('OverseerRestartLast', function()
  local overseer = require('overseer')
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify('No tasks found', vim.log.levels.WARN, { title = 'Overseer' })
  else
    overseer.run_action(tasks[1], 'restart')
  end
end, {})

local problem_matcher_mapping = {
  gcc = '$gcc',
  reach = '$gcc',
}

vim.api.nvim_create_user_command('OverseerFromTerminal', function()
  -- Use last line of the terminal buffer
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local cmd = vim.api.nvim_buf_get_lines(0, cursor_row - 1, cursor_row, false)[1]
  cmd = cmd:gsub('^%S+%s*', '')
  cmd = cmd:gsub('%s*%S+$', '')

  -- Find problem matcher form the first word of the command
  local first_word = cmd:match('^%S+')
  local problem_matcher_component = {}
  local problem_matcher = problem_matcher_mapping[first_word]
  if problem_matcher then
    problem_matcher_component = { 'on_output_parse', problem_matcher }
  end
  require('overseer').new_task({ cmd = cmd, components = { { 'default', problem_matcher_component } } }):start()
end, {})

return {
  'stevearc/overseer.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>xr', '<cmd>OverseerRun<cr>', desc = 'Overseer Run' },
    { '<leader>xi', '<cmd>OverseerInfo<cr>', desc = 'Overseer Info' },
    { '<leader>xo', '<cmd>OverseerToggle<cr>', desc = 'Overseer Toggle' },
    { '<leader>xa', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer Restart Last' },
    { '<leader>xs', '<cmd>OverseerFromTerminal<cr>', desc = 'Overseer From Terminal' },
  },
  opts = {
    strategy = {
      'toggleterm',
      use_shell = true,
      open_on_start = false,
      close_on_exit = false,
      hidden = false,
      quit_on_exit = 'never',
    },
    task_list = {
      direction = 'right',
    },
    form = {
      win_opts = {
        winblend = vim.o.pumblend,
      },
    },
  },
}
