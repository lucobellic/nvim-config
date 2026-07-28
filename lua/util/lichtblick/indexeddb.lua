local config = require('util.lichtblick.config')
local file = require('util.lichtblick.file')

---@class Lichtblick.IndexedDBRecord
---@field namespace? string
---@field layout? table

---@class Lichtblick.IndexedDBPayload
---@field database string
---@field records Lichtblick.IndexedDBRecord[]

---@class Lichtblick.StoredLayout
---@field data table
---@field database string
---@field id string
---@field name string
---@field namespace string
---@field source string

---@class Lichtblick.IndexedDBModule
---@field read fun(): Lichtblick.StoredLayout[]|nil, string|nil Read layouts from Lichtblick IndexedDB.
---@field discover_scripts fun(): Lichtblick.Script[]|nil, string|nil Discover scripts from IndexedDB layouts.
---@field save_script fun(metadata: Lichtblick.IndexedDBMetadata, script_id: string, source_code: string): boolean, string|nil Save a script and create a backup.
---@type Lichtblick.IndexedDBModule
local M = {}

---Invoke the Node helper over Lichtblick's remote debugging connection.
---@param operation 'read'|'write-script'
---@param input? table
---@return table|nil payload
---@return string|nil error
local function run_helper(operation, input)
  local helper = vim.fn.stdpath('config') .. '/lua/util/lichtblick/indexeddb.mjs'
  local result = vim
    .system({ 'node', helper, tostring(config.debug_port), operation }, {
      stdin = input and vim.json.encode(input) or nil,
      text = true,
    })
    :wait()
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or '')
  end

  local ok, payload = pcall(vim.json.decode, result.stdout)
  if not ok or type(payload) ~= 'table' then
    return nil, 'Lichtblick returned an invalid response'
  end
  return payload
end

---Read and validate the IndexedDB helper response.
---@return Lichtblick.IndexedDBPayload|nil payload
---@return string|nil error
local function read_payload()
  local payload, err = run_helper('read')
  if not payload or type(payload.records) ~= 'table' then
    return nil, err or 'Lichtblick returned invalid IndexedDB data'
  end
  return payload
end

---Check whether Lichtblick's Chrome DevTools endpoint is reachable.
---@return boolean
local function debug_endpoint_available()
  local script = [[
    const port = process.argv[1];
    fetch(`http://127.0.0.1:${port}/json/list`, { signal: AbortSignal.timeout(750) })
      .then((response) => process.exit(response.ok ? 0 : 1))
      .catch(() => process.exit(1));
  ]]
  return vim.system({ 'node', '-e', script, tostring(config.debug_port) }, { timeout = 1000 }):wait().code == 0
end

---Return the oldest running Lichtblick process identifier.
---@return integer|nil
local function running_pid()
  if vim.fn.executable('pgrep') ~= 1 then
    return nil
  end

  local process_name = vim.fn.fnamemodify(config.lichtblick_executable, ':t')
  local result = vim.system({ 'pgrep', '-o', '-x', process_name }, { text = true }):wait()
  return result.code == 0 and tonumber(vim.trim(result.stdout)) or nil
end

---Restart Lichtblick with a local remote-debugging endpoint.
---@return boolean started
---@return string|nil error
local function start_debug_instance()
  if vim.fn.executable(config.lichtblick_executable) ~= 1 then
    return false, ('Lichtblick executable was not found: %s'):format(config.lichtblick_executable)
  end

  local pid = running_pid()
  if pid then
    local choice = vim.fn.confirm(
      'Lichtblick is running without remote debugging. Restart it now? Unsaved in-memory changes may be lost.',
      '&Restart\n&Cancel',
      2
    )
    if choice ~= 1 then
      return false, 'Lichtblick restart cancelled'
    end

    local kill_ok, kill_err = vim.uv.kill(pid, 15)
    if kill_ok == nil then
      return false, ('Cannot stop Lichtblick: %s'):format(kill_err)
    end
    local stopped = vim.wait(5000, function() return running_pid() == nil end, 100)
    if not stopped then
      return false, 'Lichtblick did not stop after SIGTERM; restart it manually'
    end
  end

  local job = vim.fn.jobstart({
    config.lichtblick_executable,
    '--remote-debugging-address=127.0.0.1',
    ('--remote-debugging-port=%d'):format(config.debug_port),
  }, { detach = true })
  if job <= 0 then
    return false, 'Failed to start Lichtblick with remote debugging'
  end

  local ready = vim.wait(config.debug_start_timeout, debug_endpoint_available, 250)
  if not ready then
    return false, ('Lichtblick debug endpoint did not start on port %d'):format(config.debug_port)
  end
  return true
end

---Read IndexedDB data, optionally starting a debuggable Lichtblick instance.
---@return Lichtblick.IndexedDBPayload|nil payload
---@return string|nil error
local function payload_with_debug_start()
  local payload, read_err = read_payload()
  if payload or debug_endpoint_available() or not config.auto_start_debug then
    return payload, read_err
  end

  vim.notify('Starting Lichtblick with remote debugging...', vim.log.levels.INFO, { title = 'Lichtblick' })
  local started, start_err = start_debug_instance()
  if not started then
    return nil, start_err
  end

  local loaded = vim.wait(config.debug_start_timeout, function()
    payload, read_err = read_payload()
    return payload ~= nil
  end, 250)
  if not loaded then
    return nil, ('Lichtblick started, but IndexedDB was not ready: %s'):format(read_err)
  end
  return payload
end

---@param layout table
---@return table|nil data
---@return string|nil source
---Select the current data payload from a stored layout's supported shapes.
local function current_data(layout)
  if type(layout.working) == 'table' and type(layout.working.data) == 'table' then
    return layout.working.data, 'working'
  end
  if type(layout.baseline) == 'table' and type(layout.baseline.data) == 'table' then
    return layout.baseline.data, 'baseline'
  end
  if type(layout.data) == 'table' then
    return layout.data, 'legacy data'
  end
  if type(layout.state) == 'table' then
    return layout.state, 'legacy state'
  end
end

---Read all available layouts from Lichtblick IndexedDB.
---@return Lichtblick.StoredLayout[]|nil layouts
---@return string|nil error
function M.read()
  if vim.fn.executable('node') ~= 1 then
    return nil, 'Node.js is required to read Lichtblick IndexedDB'
  end

  local payload, read_err = payload_with_debug_start()
  if not payload then
    return nil,
      (
        'Cannot connect to Lichtblick on port %d. Start it with '
        .. '`lichtblick --remote-debugging-address=127.0.0.1 --remote-debugging-port=%d`. %s'
      ):format(config.debug_port, config.debug_port, read_err)
  end

  local layouts = {}
  for _, record in ipairs(payload.records) do
    local stored_layout = type(record) == 'table' and record.layout or nil
    local data, source
    if type(stored_layout) == 'table' then
      data, source = current_data(stored_layout)
    end
    if data then
      table.insert(layouts, {
        data = data,
        database = payload.database,
        id = stored_layout.id,
        name = stored_layout.name or stored_layout.id or 'unnamed-layout',
        namespace = record.namespace or 'unknown',
        source = source,
      })
    end
  end

  table.sort(layouts, function(left, right) return left.name < right.name end)
  return layouts
end

---Discover editable user scripts in IndexedDB layouts.
---@return Lichtblick.Script[]|nil scripts
---@return string|nil error
function M.discover_scripts()
  local layouts, err = M.read()
  if not layouts then
    return nil, err
  end

  local scripts = {}
  for _, stored_layout in ipairs(layouts) do
    if type(stored_layout.data.userNodes) == 'table' then
      for script_id, script in pairs(stored_layout.data.userNodes) do
        if
          type(script_id) == 'string'
          and type(script) == 'table'
          and type(script.name) == 'string'
          and type(script.sourceCode) == 'string'
        then
          table.insert(scripts, {
            id = script_id,
            indexeddb = {
              database = stored_layout.database,
              id = stored_layout.id,
              namespace = stored_layout.namespace,
            },
            layout_name = stored_layout.name,
            name = script.name,
            source_code = script.sourceCode,
          })
        end
      end
    end
  end
  return scripts
end

---Back up the containing record and update one IndexedDB user script.
---@param metadata Lichtblick.IndexedDBMetadata
---@param script_id string
---@param source_code string
---@return boolean success
---@return string|nil backup_path_or_error
function M.save_script(metadata, script_id, source_code)
  if vim.fn.executable('node') ~= 1 then
    return false, 'Node.js is required to write Lichtblick IndexedDB'
  end

  local payload, read_err = payload_with_debug_start()
  if not payload then
    return false, read_err
  end
  if payload.database ~= metadata.database then
    return false, ('Expected IndexedDB %s, but Lichtblick opened %s'):format(metadata.database, payload.database)
  end

  local record
  for _, candidate in ipairs(payload.records) do
    if
      candidate.namespace == metadata.namespace
      and type(candidate.layout) == 'table'
      and candidate.layout.id == metadata.id
    then
      record = candidate
      break
    end
  end
  if not record then
    return false, ('Layout %s no longer exists in Lichtblick IndexedDB'):format(metadata.id)
  end

  local backup_dir = config.project_dir .. '/backups'
  if vim.fn.mkdir(backup_dir, 'p') == 0 and vim.fn.isdirectory(backup_dir) ~= 1 then
    return false, ('Cannot create IndexedDB backup directory: %s'):format(backup_dir)
  end
  local timestamp = os.date('%Y%m%d-%H%M%S')
  local backup_path = ('%s/%s-%s-%s.json'):format(backup_dir, metadata.id, timestamp, vim.uv.hrtime())
  local backup_ok, backup_err = file.atomic_write(backup_path, vim.json.encode(record))
  if not backup_ok then
    return false, ('Cannot back up Lichtblick layout record: %s'):format(backup_err)
  end

  local result, write_err = run_helper('write-script', {
    database = metadata.database,
    namespace = metadata.namespace,
    layoutId = metadata.id,
    scriptId = script_id,
    sourceCode = source_code,
  })
  if not result or result.updated ~= true then
    return false, ('Cannot update Lichtblick IndexedDB: %s'):format(write_err)
  end
  return true, backup_path
end

return M
