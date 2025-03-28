-- TODO: set and test problem matcher (python/cpp) such as tasks.json
local cmake_targets = nil

local function cmake_build()
  local Job = require('plenary.job')
  local overseer = require('overseer')
  if not cmake_targets then
    ---@diagnostic disable-next-line: missing-fields
    Job:new({
      command = 'cmake',
      args = { '--build', '../build', '--target', 'help' },
      on_exit = function(j, exit_code)
        if exit_code ~= 0 then
          vim.notify('Failed to get cmake targets', vim.log.levels.ERROR)
        else
          -- Remove invalid targets
          local targets = vim.tbl_filter(function(target)
            local first_char = target:sub(1, 1)
            local is_invalid = first_char == '/'
              or first_char == '_'
              or first_char == '['
              or first_char == '-'
              or first_char == '.'
            return not is_invalid
          end, j:result())

          -- Remove ': phony' from target names
          cmake_targets = vim.tbl_map(function(target) return target:gsub(': phony', '') end, targets)

          vim.notify('CMake targets cache updated', vim.log.levels.INFO)
        end
      end,
    }):start()
  else
    vim.ui.select(cmake_targets, { prompt = 'Select cmake target' }, function(choice)
      if choice then
        overseer
          .new_task({
            name = 'CMake build ' .. choice,
            cmd = 'cmake',
            args = { '--build', '../build', '-j', '6', '--target', choice },
            components = { 'default', 'default_vscode' },
          })
          :start()
      end
    end)
  end
end

local function get_reach_result(args)
  local Job = require('plenary.job')
  local results = {}
  ---@diagnostic disable-next-line: missing-fields
  Job:new({
    command = 'reach',
    args = args,
    on_exit = function(j, exit_code)
      if exit_code ~= 0 then
        vim.notify('Failed to load tests', vim.log.levels.ERROR)
      else
        results = j:result()
      end
    end,
  }):sync()
  return results
end

local function reach_run(run_args, list_args)
  local overseer = require('overseer')
  local results = get_reach_result(list_args)
  vim.ui.select(results, { prompt = 'Select' }, function(choice)
    if choice then
      table.insert(run_args, choice)
      overseer
        .new_task({
          name = choice,
          cmd = 'reach',
          args = run_args,
          components = { 'default' },
        })
        :start()
    end
  end)
end

vim.keymap.set(
  'n',
  '<leader>oet',
  function() reach_run({ 'test', 'run', '-b' }, { 'test', 'list' }) end,
  { desc = 'Reach Test' }
)

vim.keymap.set(
  'n',
  '<leader>oes',
  function() reach_run({ 'simu', 'run' }, { 'simu', 'list' }) end,
  { desc = 'Reach Simu' }
)

local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add({ { '<leader>oe', group = 'easymile' } })
end

vim.keymap.set('n', '<leader>oeb', cmake_build, { desc = 'CMake Build Target', repeatable = true })
vim.keymap.set('n', '<leader>oec', function() cmake_targets = nil end, { desc = 'CMake Clear Target Cache' })
