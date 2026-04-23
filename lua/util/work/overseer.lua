local cache_dir = vim.fn.stdpath('cache') .. '/cmake_targets'

local target_format = {
  EXECUTABLE = { icon = ' ', hl = 'DiagnosticOk' },
  SHARED_LIBRARY = { icon = ' ', hl = 'DiagnosticHint' },
  STATIC_LIBRARY = { icon = ' ', hl = 'DiagnosticWarn' },
  MODULE_LIBRARY = { icon = ' ', hl = 'DiagnosticError' },
  OBJECT_LIBRARY = { icon = ' ', hl = 'DiagnosticInfo' },
  INTERFACE_LIBRARY = { icon = ' ', hl = 'Comment' },
  UTILITY = { icon = ' ', hl = 'Comment' },
}

--- Read and decode a JSON file, returning nil on failure.
---@param path string
---@return table|nil
local function read_json(path)
  local file = io.open(path, 'r')
  if not file then
    return nil
  end
  local content = file:read('*all')
  file:close()
  local ok, data = pcall(vim.json.decode, content)
  return ok and data or nil
end

-- ── CMake target cache ──────────────────────────────────────────────

local function get_project_id()
  local cwd = vim.fn.getcwd()
  return vim.fn.fnamemodify(cwd, ':t') .. '_' .. vim.fn.sha256(cwd):sub(1, 8)
end

local function get_cache_file()
  vim.fn.mkdir(cache_dir, 'p')
  return cache_dir .. '/' .. get_project_id() .. '.json'
end

---@param targets {name: string, type: string}[]
local function save_cmake_cache(targets)
  vim.g['cmake_targets_' .. get_project_id()] = targets
  local file = io.open(get_cache_file(), 'w')
  if file then
    file:write(vim.json.encode(targets))
    file:close()
  end
end

---@return {name: string, type: string}[]|nil
local function load_cmake_targets()
  local key = 'cmake_targets_' .. get_project_id()
  if not vim.g[key] then
    vim.g[key] = read_json(get_cache_file())
  end
  return vim.g[key]
end

local function clear_cmake_cache()
  vim.g['cmake_targets_' .. get_project_id()] = nil
  os.remove(get_cache_file())
  vim.notify('CMake cache cleared', vim.log.levels.INFO, { title = 'CMake' })
end

-- ── CMake file-API ──────────────────────────────────────────────────

---@param build_dir string
local function ensure_fileapi_query(build_dir)
  local query_dir = build_dir .. '/.cmake/api/v1/query'
  vim.fn.mkdir(query_dir, 'p')
  local query_file = query_dir .. '/codemodel-v2'
  if vim.fn.filereadable(query_file) == 0 then
    local f = io.open(query_file, 'w')
    if f then
      f:close()
    end
  end
end

--- Collect target json file paths from a codemodel reply.
---@param reply_dir string
---@param index_data table
---@return string[]|nil
local function get_target_files(reply_dir, index_data)
  local cm_ref = vim.iter(index_data.objects or {}):find(function(obj) return obj.kind == 'codemodel' end)
  if not cm_ref then
    return nil
  end

  local cm_data = read_json(reply_dir .. '/' .. cm_ref.jsonFile)
  if not cm_data then
    return nil
  end

  return vim
    .iter(cm_data.configurations or {})
    :map(function(cfg) return cfg.targets or {} end)
    :flatten()
    :filter(function(ref) return ref.jsonFile ~= nil end)
    :map(function(ref) return reply_dir .. '/' .. ref.jsonFile end)
    :totable()
end

---@param build_dir string
---@return {name: string, type: string}[]|nil
local function read_fileapi_targets(build_dir)
  local reply_dir = build_dir .. '/.cmake/api/v1/reply'
  local index_files = vim.fn.glob(reply_dir .. '/index-*.json', false, true)
  if not index_files or #index_files == 0 then
    return nil
  end

  table.sort(index_files)
  local index_data = read_json(index_files[#index_files])
  if not index_data then
    return nil
  end

  local target_files = get_target_files(reply_dir, index_data)
  if not target_files then
    return nil
  end

  return vim
    .iter(target_files)
    :map(read_json)
    :filter(function(d) return d and d.name and d.type end)
    :map(function(d) return { name = d.name, type = d.type } end)
    :unique(function(d) return d.name end)
    :totable()
end

--- Parse custom targets from cmake/custom_targets.cmake.
---@return {name: string, type: string}[]
local function read_custom_targets()
  local path = vim.fn.getcwd() .. '/cmake/custom_targets.cmake'
  if vim.fn.filereadable(path) ~= 1 then
    return {}
  end

  local file = io.open(path, 'r')
  if not file then
    return {}
  end

  local targets = vim
    .iter(file:lines())
    :map(function(line) return line:match('add_custom_target%(([%w_%-]+)') end)
    :filter(function(name) return name ~= nil end)
    :map(function(name) return { name = name, type = 'UTILITY' } end)
    :totable()
  file:close()
  return targets
end

--- Resolve targets: return cached or scan file-API + custom targets.
---@return {name: string, type: string}[]|nil
local function resolve_cmake_targets()
  local cached = load_cmake_targets()
  if cached then
    return cached
  end

  local build_dir = vim.fn.resolve(vim.fn.getcwd() .. '/../build')
  ensure_fileapi_query(build_dir)

  local targets = read_fileapi_targets(build_dir)
  if not targets or #targets == 0 then
    vim.notify(
      'No CMake file-API reply found. Re-run cmake configure then refresh the cache (<leader>oec).',
      vim.log.levels.WARN,
      { title = 'CMake' }
    )
    return nil
  end

  vim.list_extend(targets, read_custom_targets())
  save_cmake_cache(targets)
  vim.notify('CMake targets cache updated via file-API', vim.log.levels.INFO, { title = 'CMake' })
  return targets
end

-- ── CMake build picker ──────────────────────────────────────────────

---@param item snacks.picker.finder.Item
---@return snacks.picker.Highlight[]
local function format_cmake_target(item)
  local target = item.item ---@type {name: string, type: string}
  local kind = target.type or 'UTILITY'
  return {
    { target_format[kind].icon or '  ', target_format[kind].hl or 'Normal' },
    { target.name, 'Normal' },
  }
end

---@param choices snacks.picker.finder.Item[]
local function run_cmake_builds(choices)
  local overseer = require('overseer')
  vim.iter(choices):each(function(choice)
    local target = choice.item ---@type {name: string, type: string}
    overseer
      .new_task({
        name = 'CMake build ' .. target.name,
        cmd = 'cmake',
        args = { '--build', '../build', '-j', '8', '--target', target.name },
        components = { 'default', 'default_vscode' },
      })
      :start()
  end)
end

local function cmake_build()
  local targets = resolve_cmake_targets()
  if not targets then
    return
  end

  ---@type snacks.picker.finder.Item[]
  local items = vim
    .iter(ipairs(targets))
    :map(
      function(idx, target)
        return { formatted = target.name, text = idx .. ' ' .. target.name, item = target, idx = idx }
      end
    )
    :totable()

  Snacks.picker.pick({
    source = 'work_cmake_targets',
    items = items,
    format = format_cmake_target,
    title = 'CMake Build Target',
    layout = { preset = 'vscode' },
    actions = {
      confirm = function(picker, item)
        picker:close()
        vim.schedule(function()
          local selected = picker:selected()
          local choices = (selected and #selected > 0) and selected or (item and { item } or {})
          if #choices > 0 then
            run_cmake_builds(choices)
          else
            vim.notify('No cmake target selected', vim.log.levels.WARN)
          end
        end)
      end,
    },
  })
end

-- ── Reach ───────────────────────────────────────────────────────────

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
  require('util.util').multi_select(results, { prompt = 'Select Reach Test' }, function(choices)
    if not choices or #choices == 0 then
      vim.notify('No Reach test selected', vim.log.levels.WARN)
      return
    end
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
  end)
end

-- ── Debug executable picker ─────────────────────────────────────────

---@return snacks.picker.finder.Item[]
local function scan_executables()
  local scan = require('plenary.scandir')
  local dirs = {
    vim.fn.resolve(vim.fn.getcwd() .. '/../build/Executables'),
    vim.fn.resolve(vim.fn.getcwd() .. '/../build/Libs'),
    vim.fn.resolve(vim.fn.getcwd() .. '/../build/bindev'),
  }

  return vim
    .iter(dirs)
    :filter(function(dir) return vim.fn.isdirectory(dir) == 1 end)
    :map(function(dir)
      return vim
        .iter(scan.scan_dir(dir, { hidden = false, add_dirs = false, depth = 10 }))
        :filter(function(file) return vim.fn.executable(file) == 1 end)
        :map(function(file) return { text = file:sub(#dir + 2), path = file } end)
        :totable()
    end)
    :flatten()
    :totable()
end

---@param executable_path string
---@param executable_name string
---@param args string[]
local function launch_dap(executable_path, executable_name, args)
  require('dap').run({
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
      { description = 'Enable pretty-printing for gdb', text = '-enable-pretty-printing', ignoreFailures = true },
      {
        description = 'Set Disassembly Flavor to Intel',
        text = '-gdb-set disassembly-flavor intel',
        ignoreFailures = true,
      },
    },
  })
end

local function reach_debug_test()
  local items = scan_executables()
  if #items == 0 then
    vim.notify('No executable files found in any build directory', vim.log.levels.WARN)
    return
  end

  Snacks.picker.pick({
    source = 'work_debug_executables',
    title = 'Select Executable to Debug',
    items = items,
    format = 'text',
    layout = { preset = 'vscode' },
    actions = {
      confirm = function(picker, item)
        if not item then
          return
        end
        picker:close()
        vim.schedule(function()
          vim.ui.input({ prompt = 'Arguments (optional): ', default = '' }, function(input)
            if input == nil then
              return
            end
            local args = input ~= '' and vim.split(input, '%s+') or {}
            launch_dap(item.path, item.text, args)
          end)
        end)
      end,
    },
  })
end

-- ── Keymaps ─────────────────────────────────────────────────────────

local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add({ { '<leader>oe', group = 'easymile' } })
end

vim.keymap.set('n', '<leader>oeb', cmake_build, { desc = 'CMake Build Target', repeatable = true })
vim.keymap.set('n', '<leader>oec', clear_cmake_cache, { desc = 'CMake Clear Target Cache' })
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
