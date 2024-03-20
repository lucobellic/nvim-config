vim.api.nvim_create_user_command('OverseerRestartLast', function()
  local overseer = require('overseer')
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify('No tasks found', vim.log.levels.WARN, { title = 'Overseer' })
  else
    overseer.run_action(tasks[1], 'restart')
  end
end, {})

vim.api.nvim_create_user_command('OverseerFromTerminal', function()
  -- Use last line of the terminal buffer
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local cmd = vim.api.nvim_buf_get_lines(0, cursor_row - 1, cursor_row, false)[1]
  cmd = cmd:gsub('^%S+%s*', '')
  cmd = cmd:gsub('%s*%S+$', '')

  vim.notify('Start: ' .. cmd, vim.log.levels.INFO, { title = 'Overseer' })
  require('overseer').new_task({ cmd = cmd }):start()
end, {})

local function open_first_failed_task()
  local overseer = require('overseer')
  local constants = require('overseer.constants')
  local action_util = require('overseer.action_util')
  local failed_tasks = overseer.list_tasks({ status = constants.STATUS.FAILURE })
  if #failed_tasks > 0 then
    local task = failed_tasks[1] ---@type overseer.Task
    action_util.run_task_action(task, 'open hsplit')
  else
    vim.notify('No failed tasks found', vim.log.levels.WARN, { title = 'Overseer' })
  end
end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>o'] = { name = 'overseer/obsidian' },
      },
    },
  },
  {
    -- 'stevearc/overseer.nvim',
    'lucobellic/overseer.nvim',
    branch = 'feature/rustc-problem-matcher ',
    cmd = { 'OverseerRun', 'OverseerInfo', 'OverseerToggle', 'OverseerFromTerminal' },
    keys = {
      { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Overseer Run' },
      { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Overseer Info' },
      { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = 'Overseer Toggle' },
      { '<leader>oa', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer Restart Last' },
      { '<leader>ol', '<cmd>OverseerTaskAction<cr>', desc = 'Overseer Task Action' },
      { '<leader>ox', '<cmd>OverseerFromTerminal<cr>', desc = 'Overseer From Terminal' },
      { '<leader>op', open_first_failed_task, desc = 'Overseer Open Failed Task' },
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
        bindings = {
          ['<C-h>'] = '<C-w>h',
          ['<C-j>'] = '<C-w>j',
          ['<C-k>'] = '<C-w>k',
          ['<C-l>'] = '<C-w>l',
        },
      },
      templates = { 'builtin', 'user.script' },
      form = {
        win_opts = {
          winblend = vim.o.pumblend,
        },
      },
      component_aliases = {
        default = {
          { 'display_duration', detail_level = 2 },
          'user.on_output_parse', -- parse with problem matcher
          'on_output_quickfix', -- parse errorformat
          'on_exit_set_status',
          'on_complete_notify',
          { 'on_result_diagnostics', remove_on_restart = true, underline = false },
          'on_result_diagnostics_quickfix',
          {'unique'}
        },
        default_vscode = {
          'default',
        },
      },
    },
    dev = true,
  },
}
