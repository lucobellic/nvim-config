--- @class SystemStatsCache
--- @field cpu string
--- @field gpu string
--- @field memory string
--- @field cpu_job Job|nil
--- @field gpu_job Job|nil
--- @field memory_job Job|nil

--- @class SystemStats
--- @field system_stats_cache SystemStatsCache
local M = {
  system_stats_cache = {
    cpu = '  ',
    gpu = '  ',
    memory = ' ',
    cpu_job = nil,
    gpu_job = nil,
    memory_job = nil,
  },
}

-- Function to get CPU usage asynchronously
function M.update_cpu_usage_async()
  local Job = require('plenary.job')
  --- @diagnostic disable-next-line: missing-fields
  if M.cpu_job and M.cpu_job:is_job() then
    return
  end

  ---@diagnostic disable-next-line: missing-fields
  M.cpu_job = Job:new({
    command = 'sh',
    args = { '-c', "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1" },
    on_exit = function(j, return_val)
      if return_val == 0 then
        local result = table.concat(j:result(), '\n')
        local cleaned_result = result:gsub('^%s*(.-)%s*$', '%1'):gsub(',', '.')
        local cpu_value = tonumber(cleaned_result) or 0
        M.system_stats_cache.cpu = ' ' .. M.create_vertical_bar(cpu_value)

        -- Trigger user command when CPU has been updated
        vim.schedule(
          function()
            vim.api.nvim_exec_autocmds('User', {
              pattern = 'CpuUpdated',
            })
          end
        )

        M.cpu_job = nil -- reset the job after completion
      end
    end,
  })

  M.cpu_job:start()
end

-- Function to get GPU usage asynchronously (NVIDIA)
function M.update_gpu_usage_async()
  local Job = require('plenary.job')
  --- @diagnostic disable-next-line: missing-fields
  if M.gpu_job and M.gpu_job:is_job() then
    return
  end

  --- @diagnostic disable-next-line: missing-fields
  M.gpu_job = Job:new({
    command = 'nvidia-smi',
    args = { '--query-gpu=utilization.gpu', '--format=csv,noheader,nounits' },
    on_exit = function(j, return_val)
      if return_val == 0 then
        local result = table.concat(j:result(), '\n')
        local cleaned_result = result:gsub('^%s*(.-)%s*$', '%1'):gsub(',', '.')
        local gpu_value = tonumber(cleaned_result) or 0
        M.system_stats_cache.gpu = M.create_vertical_bar(gpu_value)

        -- Trigger user command when GPU has been updated
        vim.schedule(
          function()
            vim.api.nvim_exec_autocmds('User', {
              pattern = 'GpuUpdated',
            })
          end
        )

        M.gpu_job = nil -- reset the job after completion
      end
    end,
  })

  M.gpu_job:start()
end

-- Function to get memory usage asynchronously
function M.update_memory_usage_async()
  local Job = require('plenary.job')
  --- @diagnostic disable-next-line: missing-fields
  if M.memory_job and M.memory_job:is_job() then
    return
  end

  --- @diagnostic disable-next-line: missing-fields
  M.memory_job = Job:new({
    command = 'sh',
    args = { '-c', 'free | awk \'NR==2{printf "%.0f", $3*100/$2}\'' },
    on_exit = function(j, return_val)
      if return_val == 0 then
        local result = table.concat(j:result(), '\n')
        local cleaned_result = result:gsub('^%s*(.-)%s*$', '%1'):gsub(',', '.')
        local memory_value = tonumber(cleaned_result) or 0
        M.system_stats_cache.memory = M.create_vertical_bar(memory_value)

        -- Trigger user command when memory has been updated
        vim.schedule(function() vim.api.nvim_exec_autocmds('User', { pattern = 'MemoryUpdated' }) end)

        M.memory_job = nil -- reset the job after completion
      end
    end,
  })

  M.memory_job:start()
end

-- Function to create vertical bar based on percentage
function M.create_vertical_bar(percentage)
  local bars = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
  local clamped = math.max(0, math.min(100, percentage))

  if clamped == 0 then
    return ' '
  end

  local bar_index = math.ceil(clamped / 12.5)
  bar_index = math.max(1, math.min(8, bar_index))

  return bars[bar_index]
end

function M.start_auto_update()
  -- Create a timer only once that repeats
  if M.timer == nil then
    M.timer = vim.uv.new_timer()
    M.timer:start(0, 1000, function()
      M.update_cpu_usage_async()
      M.update_gpu_usage_async()
      M.update_memory_usage_async()
    end)
  end
end

return M
