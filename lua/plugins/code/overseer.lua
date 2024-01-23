vim.api.nvim_create_user_command('OverseerRestartLast', function()
  local overseer = require('overseer')
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify('No tasks found', vim.log.levels.WARN, { title = 'Overseer' })
  else
    overseer.run_action(tasks[1], 'restart')
  end
end, {})

local python_problem_matcher = {
  owner = 'python',
  pattern = {
    regexp = '^(.*):(\\d+):(\\d+):\\s+(\\w+):\\s+(.*)$',
    file = 1,
    line = 2,
    column = 3,
    severity = 4,
    message = 5,
  },
  fileLocation = { 'relative', '${cwd}' },
}

local problem_matcher_mapping = {
  gcc = '$gcc',
  python = python_problem_matcher,
  pytest = python_problem_matcher,
}

---Get problem matcher from command
---@param cmd string
---@return string|table|nil problem_matcher
local function get_problem_match(cmd)
  local first_word = cmd:match('^%S+')

  local problem_matcher = problem_matcher_mapping[first_word]

  if problem_matcher == nil then
    if first_word:match('reach') then
      -- Check if 'pytest' is present in the cmd string
      if cmd:match('pytest') or cmd:match('conf-test') then
        problem_matcher = problem_matcher_mapping.pytest
      end
      if cmd:match('build') then
        problem_matcher = problem_matcher_mapping.gcc
      end
    end
  end
  return problem_matcher
end

vim.api.nvim_create_user_command('OverseerFromTerminal', function()
  -- Use last line of the terminal buffer
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local cmd = vim.api.nvim_buf_get_lines(0, cursor_row - 1, cursor_row, false)[1]
  cmd = cmd:gsub('^%S+%s*', '')
  cmd = cmd:gsub('%s*%S+$', '')

  local problem_matcher_component = {}
  local problem_matcher = get_problem_match(cmd)
  if problem_matcher then
    problem_matcher_component = { 'on_output_parse', problem_matcher = problem_matcher }
  end
  vim.notify('Start: ' .. cmd, vim.log.levels.INFO, { title = 'Overseer' })
  require('overseer').new_task({ cmd = cmd, components = { problem_matcher_component, 'default' } }):start()
end, {})

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
    'stevearc/overseer.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Overseer Run' },
      { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Overseer Info' },
      { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = 'Overseer Toggle' },
      { '<leader>oa', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer Restart Last' },
      { '<leader>ox', '<cmd>OverseerFromTerminal<cr>', desc = 'Overseer From Terminal' },
    },
    opts = {
      bindings = {
        ['<C-j>'] = 'NextTask',
        ['<C-k>'] = 'PrevTask',
      },
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
  },
}
