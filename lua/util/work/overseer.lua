local cache_dir = vim.fn.stdpath('cache') .. '/cmake_targets'

local function get_project_id()
  local cwd = vim.fn.getcwd()
  -- Create a simple hash of the project path
  return vim.fn.fnamemodify(cwd, ':t') .. '_' .. vim.fn.sha256(cwd):sub(1, 8)
end

local function get_cache_file()
  vim.fn.mkdir(cache_dir, 'p')
  return cache_dir .. '/' .. get_project_id() .. '.json'
end

local function load_cmake_cache()
  local file = io.open(get_cache_file(), 'r')
  if file then
    local content = file:read('*all')
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    return ok and data or nil
  end
  return nil
end

local function save_cmake_cache(targets)
  local project_key = 'cmake_targets_' .. get_project_id()
  vim.g[project_key] = targets
  local file = io.open(get_cache_file(), 'w')
  if file then
    file:write(vim.json.encode(targets))
    file:close()
  end
end

local function get_cmake_targets()
  local project_key = 'cmake_targets_' .. get_project_id()
  if not vim.g[project_key] then
    vim.g[project_key] = load_cmake_cache()
  end
  return vim.g[project_key]
end

local function cmake_build()
  local Job = require('plenary.job')
  local overseer = require('overseer')
  local cached_targets = get_cmake_targets()

  if not cached_targets then
    local custom_targets = {}
    -- Also list all custom targets from 'cmake/custom_targets.txt' if the file is present
    -- Parse all `add_custom_target(<name> ...)` lines to extract <name>
    local file_path = vim.fn.getcwd() .. '/cmake/custom_targets.cmake'
    if vim.fn.filereadable(file_path) == 1 then
      local custom_file = io.open(file_path, 'r')
      if custom_file then
        custom_targets = vim
          .iter(custom_file:lines())
          :map(function(line) return line:match('add_custom_target%(([%w_%-]+)') end)
          :filter(function(name) return name ~= nil end)
          :totable()
        custom_file:close()
      end
    else
      vim.notify('No custom targets file found at ' .. file_path, vim.log.levels.INFO, { title = 'CMake' })
    end

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
          local cleaned_targets = vim.tbl_map(function(target) return target:gsub(': phony', '') end, targets)
          cleaned_targets = vim.list_extend(cleaned_targets, custom_targets)

          vim.schedule(function() save_cmake_cache(cleaned_targets) end)
          vim.notify('CMake targets cache updated', vim.log.levels.INFO, { title = 'CMake' })
        end
      end,
    }):start()
  else
    require('util.util').multi_select(cached_targets, { prompt = 'Select cmake target' }, function(choices)
      if choices and #choices > 0 then
        vim.iter(choices):each(
          function(choice)
            overseer
              .new_task({
                name = 'CMake build ' .. choice,
                cmd = 'cmake',
                args = { '--build', '../build', '-j', '8', '--target', choice },
                components = { 'default', 'default_vscode' },
              })
              :start()
          end
        )
      else
        vim.notify('No cmake target selected', vim.log.levels.WARN)
      end
    end)
  end
end

local function clear_cmake_cache()
  vim.notify('Clearing CMake cache...', vim.log.levels.INFO)
  local project_key = 'cmake_targets_' .. get_project_id()
  vim.g[project_key] = nil
  os.remove(get_cache_file())
  vim.notify('CMake cache cleared', vim.log.levels.INFO, { title = 'CMake' })
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
  require('util.util').multi_select(results, {
    prompt = 'Select Reach Test',
  }, function(choices)
    if choices and #choices > 0 then
      vim.iter(choices):each(function(choice)
        local args = vim.deepcopy(run_args)
        overseer
          .new_task({
            name = choice,
            cmd = 'reach',
            args = vim.list_extend(args, { choice }),
            components = { 'default' },
          })
          :start()
      end)
    else
      vim.notify('No Reach test selected', vim.log.levels.WARN)
    end
  end)
end

local function reach_debug_test()
  local executables_dirs = {
    vim.fn.resolve(vim.fn.getcwd() .. '/../build/Executables'),
    vim.fn.resolve(vim.fn.getcwd() .. '/../build/bindev'),
  }

  -- Use plenary to scan directory recursively
  local scan = require('plenary.scandir')
  local items = {}

  -- Scan all directories and collect executables
  items = vim
    .iter(executables_dirs)
    :filter(function(dir) return vim.fn.isdirectory(dir) == 1 end)
    :map(function(executables_dir)
      local files = scan.scan_dir(executables_dir, {
        hidden = false,
        add_dirs = false,
        depth = 10,
      })

      -- Filter for executable files and create items
      return vim
        .iter(files)
        :filter(function(file) return vim.fn.executable(file) == 1 end)
        :map(function(file)
          -- Store relative path from executables_dir for display
          local relative_path = file:sub(#executables_dir + 2) -- +2 to remove leading '/'
          return {
            text = relative_path,
            path = file,
          }
        end)
        :totable()
    end)
    :flatten()
    :totable()

  if #items == 0 then
    vim.notify('No executable files found in any build directory', vim.log.levels.WARN)
    return
  end

  Snacks.picker.pick({
    title = 'Select Executable to Debug',
    items = items,
    format = 'text',
    preview = function() return false end,
    layout = 'vscode',
    actions = {
      confirm = function(picker, item)
        if not item then
          return
        end

        picker:close()

        vim.schedule(function()
          -- Prompt for optional arguments
          vim.ui.input({
            prompt = 'Arguments (optional): ',
            default = '',
          }, function(input)
            if input == nil then
              return
            end

            local dap = require('dap')
            local executable_name = item.text
            local executable_path = item.path

            -- Parse arguments string into table
            local args = {}
            if input and input ~= '' then
              for arg in input:gmatch('%S+') do
                table.insert(args, arg)
              end
            end

            -- Create DAP configuration for this executable
            local config = {
              name = 'Debug: ' .. executable_name,
              type = 'cppdbg',
              request = 'launch',
              program = executable_path,
              args = args,
              cwd = vim.fn.getcwd(),
              stopAtEntry = false,
              environment = {},
              externalConsole = false,
              MIMode = 'gdb',
              setupCommands = {
                {
                  description = 'Enable pretty-printing for gdb',
                  text = '-enable-pretty-printing',
                  ignoreFailures = true,
                },
                {
                  description = 'Set Disassembly Flavor to Intel',
                  text = '-gdb-set disassembly-flavor intel',
                  ignoreFailures = true,
                },
              },
            }

            -- Start the debug session
            dap.run(config)
          end)
        end)
      end,
    },
  })
end

vim.keymap.set(
  'n',
  '<leader>oet',
  function() reach_run({ 'test', 'run', '-b' }, { 'test', 'list' }) end,
  { desc = 'Reach Test' }
)

vim.keymap.set('n', '<leader>oed', reach_debug_test, { desc = 'Reach Test (Debug)' })

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
vim.keymap.set('n', '<leader>oec', clear_cmake_cache, { desc = 'CMake Clear Target Cache' })
