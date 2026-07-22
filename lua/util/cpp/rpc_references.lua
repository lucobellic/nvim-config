local M = {}
local ports_by_root = {}

---@class EziPort
---@field direction 'in'|'out'
---@field kind 'port'|'rpc_port'
---@field name string
---@field channel string

---@param value string
---@return string
local function camel_to_snake(value) return value:gsub('(%u)(%u%l)', '%1_%2'):gsub('(%l)(%u)', '%1_%2'):lower() end

---@param bufnr integer
---@return string?
local function workspace_root(bufnr)
  local client = vim.iter(vim.lsp.get_clients({ bufnr = bufnr })):find(function(item) return item.name == 'clangd' end)
  if client and client.root_dir then
    return client.root_dir
  end
  return vim.fs.root(bufnr, { '.git' })
end

---@param line string
---@return EziPort?
local function parse_port(line)
  local prefix, kind, name, channel = line:match('^%s*(.-)%s+([%a_]+)%s+([%w_]+)%s*=%s*([%w_.]+)')
  local direction = prefix and prefix:match('(%a+)%s*$')
  if (direction ~= 'in' and direction ~= 'out') or (kind ~= 'port' and kind ~= 'rpc_port') then
    return nil
  end
  return { direction = direction, kind = kind, name = name, channel = channel }
end

---@param label string
---@param args string[]
---@param cwd string
---@param callback fun(matches: table[])
local function rg_json(label, args, cwd, callback)
  vim.system(args, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      if result.code > 1 then
        vim.notify(('%s search failed: %s'):format(label, result.stderr), vim.log.levels.ERROR, {
          title = 'RPC references',
        })
        callback({})
        return
      end

      local matches = {}
      vim.iter(vim.gsplit(result.stdout, '\n', { plain = true, trimempty = true })):each(function(json)
        local ok, entry = pcall(vim.json.decode, json)
        if ok and entry.type == 'match' then
          matches[#matches + 1] = entry.data
        end
      end)
      callback(matches)
    end)
  end)
end

---@param root string
---@param callback fun(ports: EziPort[])
local function ezi_ports(root, callback)
  if ports_by_root[root] then
    callback(ports_by_root[root])
    return
  end

  rg_json('EZI', { 'rg', '--json', '--glob', '*.ezi', 'port', root }, root, function(ezi_matches)
    ports_by_root[root] = vim
      .iter(ezi_matches)
      :map(function(match) return parse_port(match.lines.text) end)
      :filter(function(port) return port ~= nil end)
      :totable()
    callback(ports_by_root[root])
  end)
end

---@param root string
---@param callback_name string
---@param callback fun(items: snacks.picker.finder.Item[])
local function port_references(root, callback_name, callback)
  ezi_ports(root, function(ports)
    local server_port = camel_to_snake(callback_name)
    local servers = vim
      .iter(ports)
      :filter(function(port) return port.direction == 'in' and port.name == server_port end)
      :totable()
    if #servers == 0 then
      vim.notify(('No EZI input port named %q was found'):format(server_port), vim.log.levels.WARN, {
        title = 'RPC references',
      })
      callback({})
      return
    end

    local server_channels = {}
    vim.iter(servers):each(function(port) server_channels[port.kind .. ':' .. port.channel] = true end)
    local callers = vim
      .iter(ports)
      :filter(function(port) return port.direction == 'out' and server_channels[port.kind .. ':' .. port.channel] end)
      :totable()
    if #callers == 0 then
      vim.notify(
        ('No EZI output port is connected to %s'):format(
          table.concat(vim.iter(servers):map(function(port) return port.channel end):totable(), ', ')
        ),
        vim.log.levels.WARN,
        {
          title = 'RPC references',
        }
      )
      callback({})
      return
    end

    local names = vim.iter(callers):map(function(port) return port.name end):totable()
    local pattern = ('m_(%s)\\.(sendGoal|publish)\\('):format(table.concat(names, '|'))
    rg_json(
      'C++ port call',
      {
        'rg',
        '--json',
        '--glob',
        '*.{cpp,cc,cxx,hpp,hxx}',
        pattern,
        root,
      },
      root,
      function(cpp_matches)
        local ports_by_name = {}
        vim.iter(callers):each(function(port) ports_by_name[port.name] = port end)

        local items = vim
          .iter(cpp_matches)
          :filter(function(match)
            local member, method = match.lines.text:match('m_([%w_]+)%.([%a]+)%s*%(')
            local port = ports_by_name[member]
            return port
              and ((port.kind == 'rpc_port' and method == 'sendGoal') or (port.kind == 'port' and method == 'publish'))
          end)
          :map(function(match)
            local member = match.lines.text:match('m_([%w_]+)%.')
            local port = ports_by_name[member]
            local column = match.submatches[1] and match.submatches[1].start or 0
            local text = match.lines.text:gsub('%s+', ' '):gsub('^%s+', '')
            return {
              file = match.path.text,
              pos = { match.line_number, column },
              text = ('[%s %s] %s'):format(port.kind == 'rpc_port' and 'RPC' or 'port', port.channel, text),
            }
          end)
          :totable()
        if #items == 0 then
          vim.notify(
            ('No matching .sendGoal() or .publish() calls found for %s'):format(table.concat(names, ', ')),
            vim.log.levels.WARN,
            {
              title = 'RPC references',
            }
          )
        end
        callback(items)
      end
    )
  end)
end

---@param items snacks.picker.finder.Item[]
---@param elapsed_ms number
local function open_picker(items, elapsed_ms)
  if #items == 0 then
    vim.notify('No references found', vim.log.levels.INFO, { title = 'RPC references' })
    return nil
  end

  return Snacks.picker.pick({
    title = ('EZI References (%dms)'):format(elapsed_ms),
    items = items,
    format = 'file',
    matcher = { frecency = true },
  })
end

---@param bufnr integer
---@param win integer
---@param callback fun(items: snacks.picker.finder.Item[])
local function clangd_references(bufnr, win, callback)
  local client = vim.iter(vim.lsp.get_clients({ bufnr = bufnr })):find(function(item) return item.name == 'clangd' end)
  if not client then
    callback({})
    return
  end

  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  params.context = { includeDeclaration = true }
  client:request('textDocument/references', params, function(err, result)
    if err then
      vim.notify(('clangd references failed: %s'):format(err.message), vim.log.levels.WARN, {
        title = 'RPC references',
      })
      callback({})
      return
    end

    local locations = vim.islist(result) and result or result and { result } or {}
    local items = vim
      .iter(vim.lsp.util.locations_to_items(locations, client.offset_encoding))
      :map(
        function(location)
          return {
            file = location.filename,
            pos = { location.lnum, math.max(location.col - 1, 0) },
            text = ('[C++] %s'):format(location.text),
          }
        end
      )
      :totable()
    callback(items)
  end, bufnr)
end

---@param picker snacks.Picker
---@param enabled boolean
local function set_clangd_loading(picker, enabled)
  if picker.closed then
    return
  end
  if not picker._rpc_references_is_active then
    picker._rpc_references_is_active = picker.is_active
    picker.is_active = function(self) return self._rpc_references_loading or self._rpc_references_is_active(self) end
  end

  picker._rpc_references_loading = enabled
  picker.input:update()
  if enabled then
    picker:progress()
  end
end

---@param picker snacks.Picker
---@param items snacks.picker.finder.Item[]
local function add_clangd_items(picker, items)
  set_clangd_loading(picker, false)
  if picker.closed or #items == 0 then
    return
  end

  local existing = {}
  vim
    .iter(picker.opts.items)
    :each(function(item) existing[('%s:%d:%d'):format(item.file, item.pos[1], item.pos[2])] = true end)
  vim.iter(items):each(function(item)
    local key = ('%s:%d:%d'):format(item.file, item.pos[1], item.pos[2])
    if not existing[key] then
      picker.opts.items[#picker.opts.items + 1] = item
    end
  end)
  picker:refresh()
end

function M.find()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local root = workspace_root(bufnr)
  local callback_name = vim.fn.expand('<cword>'):match('^on(.+)$')
  if not callback_name then
    vim.notify('Place the cursor on an on<PortName> RPC callback', vim.log.levels.WARN, { title = 'RPC references' })
    return
  end
  if not root then
    vim.notify('Unable to determine clangd workspace root', vim.log.levels.WARN, { title = 'RPC references' })
    return
  end

  local started_at = vim.uv.hrtime()
  port_references(root, callback_name, function(items)
    local picker = open_picker(items, math.floor((vim.uv.hrtime() - started_at) / 1e6))
    if picker then
      set_clangd_loading(picker, true)
      clangd_references(bufnr, win, function(clangd_items) add_clangd_items(picker, clangd_items) end)
    end
  end)
end

function M.is_cpp_file() return #vim.lsp.get_clients({ bufnr = 0, name = 'clangd' }) > 0 end

return M
