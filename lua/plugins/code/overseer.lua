--- Opens the first failed task in a horizontal split
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

--- Sets up autocmds and user commands for overseer
local function setup_autocmds()
  local overseer = require('overseer')
  local task_list = require('overseer.task_list')

  -- Close overseer window when all buffers are closed
  vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
    pattern = '*',
    callback = function(ev)
      local is_terminal = vim.bo[ev.buf].buftype == 'terminal'
      local is_toggleterm_buffer = vim.fn.bufname(ev.buf):find('toggleterm')
      local is_toggleterm_task = is_terminal and is_toggleterm_buffer
      local is_toggleterm = vim.bo[ev.buf].filetype == 'toggleterm'

      if is_toggleterm or is_toggleterm_task then
        vim.defer_fn(function()
          local tasks_with_buffer = task_list.list_tasks({ filter = function(task) return task:get_bufnr() ~= nil end })
          if #tasks_with_buffer == 0 then
            overseer.close()
          end
        end, 200)
      end
    end,
  })

  --- User command to restart the last overseer task
  vim.api.nvim_create_user_command('OverseerRestartLast', function()
    local overseer = require('overseer')
    local tasks = overseer.list_tasks({ recent_first = true })
    if vim.tbl_isempty(tasks) then
      vim.notify('No tasks found', vim.log.levels.WARN, { title = 'Overseer' })
    else
      overseer.run_action(tasks[1], 'restart')
    end
  end, {})

  --- User command to create an overseer task from terminal content
  vim.api.nvim_create_user_command('OverseerFromTerminal', function()
    local cmd = ''

    -- Check if there is a visual selection
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'v' or mode == 'V' or mode == '' then
      cmd = table.concat(vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = mode }), '\n')
    end

    -- If no selection, fall back to last line of the terminal buffer
    if cmd == '' then
      local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
      cmd = vim.api.nvim_buf_get_lines(0, cursor_row - 1, cursor_row, false)[1]
      cmd = cmd:gsub('^%S+%s*', '') -- remove the first word (terminal icon such as ~)
      cmd = cmd:gsub('%s*%S+%s*$', '') -- remove the last word
    end

    vim.notify('Starting ' .. cmd, vim.log.levels.INFO, { title = 'Overseer' })
    require('overseer').new_task({ cmd = cmd }):start()
  end, {})
end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>o', group = 'overseer' },
      },
    },
  },
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerRun', 'OverseerInfo', 'OverseerToggle', 'OverseerFromTerminal' },
    keys = {
      { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Overseer Run' },
      { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Overseer Info' },
      { '<leader>ot', '<cmd>OverseerToggle<cr>', desc = 'Overseer Toggle' },
      { '<leader>oa', '<cmd>OverseerRestartLast<cr>', desc = 'Overseer Restart Last' },
      { '<leader>ol', '<cmd>OverseerTaskAction<cr>', desc = 'Overseer Task Action' },
      { '<leader>ox', '<cmd>OverseerFromTerminal<cr>', mode = { 'n', 'v' }, desc = 'Overseer From Terminal' },
      { '<leader>op', open_first_failed_task, desc = 'Overseer Open Failed Task' },
    },
    opts = {
      dap = false,
      strategy = {
        'toggleterm',
        size = 1000,
        auto_scroll = false,
        close_on_exit = false,
        hidden = false,
        open_on_start = false,
        quit_on_exit = 'never',
        use_shell = true,
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
      form = { border = vim.g.border.style, win_opts = { winblend = vim.o.pumblend } },
      config = { border = vim.g.border.style, win_opts = { winblend = vim.o.pumblend } },
      task_win = { border = vim.g.border.style, win_opts = { winblend = vim.o.pumblend } },
      help_win = { border = vim.g.border.style, win_opts = { winblend = vim.o.pumblend } },
      component_aliases = {
        default = {
          { 'user.open_on_start_if_visible', direction = 'vertical' }, -- open on start if overseer window is visible/open
          { 'display_duration', detail_level = 2 },
          'user.on_output_parse', -- parse with problem matcher
          { 'on_output_quickfix', tail = false }, -- parse errorformat
          'on_exit_set_status', -- set the status based on exit code
          'on_complete_notify', -- popup notification
          { 'on_result_diagnostics', remove_on_restart = true, underline = true }, -- display diagnostics
          'on_result_diagnostics_quickfix', -- send diagnostics to quickfix or loclist
          'unique',
          { 'user.on_complete_close_term', statuses = { 'SUCCESS' }, timeout = 5 },
        },
        default_vscode = {
          'default',
        },
      },
    },
    config = function(_, opts)
      local overseer = require('overseer')

      -- Override run_in_cwd to prevent fullscreen terminal execution and output flickering
      --- @diagnostic disable-next-line: duplicate-set-field
      require('overseer.util').run_in_cwd = function(cwd, callback)
        vim.cmd.lcd({ args = { cwd }, mods = { silent = true, noautocmd = true } })
        callback()
      end

      overseer.setup(opts)
      setup_autocmds()
    end,
  },
}
