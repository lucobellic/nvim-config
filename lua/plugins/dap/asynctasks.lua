local function select_async_tasks()
  local tasks = vim.api.nvim_call_function('asynctasks#list', { '' })

  local tasks_name = {}
  for _, task in ipairs(tasks or {}) do table.insert(tasks_name, task.name) end
  vim.ui.select(tasks_name, { prompt = 'Tasks' }, function(task_name)
    if task_name then
      vim.api.nvim_call_function('asynctasks#start', { '', task_name, '' })
    end
  end)
end


vim.api.nvim_create_user_command('TasksList', select_async_tasks, {})
