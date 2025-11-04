local Util = require('util.agents.util')

local AgentRegistry = {
  managers = {},
  last_used_manager = nil,
  _initialized = false,
}

function AgentRegistry.register(manager)
  table.insert(AgentRegistry.managers, manager)
  if not AgentRegistry.last_used_manager then
    AgentRegistry.last_used_manager = manager
  end
end

function AgentRegistry.unregister(manager)
  AgentRegistry.managers = vim.tbl_filter(function(m) return m ~= manager end, AgentRegistry.managers)
  if AgentRegistry.last_used_manager == manager then
    AgentRegistry.last_used_manager = AgentRegistry.managers[#AgentRegistry.managers] or nil
  end
end

function AgentRegistry.update_last_used(manager) AgentRegistry.last_used_manager = manager end

function AgentRegistry._ensure_manager()
  if not AgentRegistry.last_used_manager then
    vim.notify('No agent manager has been used yet', vim.log.levels.WARN)
    return false
  end
  return true
end

local function delegate_to_manager(method_name)
  return function(...)
    if not AgentRegistry._ensure_manager() then
      return
    end
    return AgentRegistry.last_used_manager[method_name](AgentRegistry.last_used_manager, ...)
  end
end

AgentRegistry.toggle = delegate_to_manager('toggle')
AgentRegistry.create = delegate_to_manager('create')
AgentRegistry.select = delegate_to_manager('select')
AgentRegistry.next = delegate_to_manager('next')
AgentRegistry.prev = delegate_to_manager('prev')
AgentRegistry.close = delegate_to_manager('close')
AgentRegistry.hide_all = delegate_to_manager('hide_all')
AgentRegistry.send_current_buffer = delegate_to_manager('send_current_buffer')
AgentRegistry.select_and_send_files = delegate_to_manager('select_and_send_files')
AgentRegistry.select_and_send_buffers = delegate_to_manager('select_and_send_buffers')
AgentRegistry.select_and_send_terminals = delegate_to_manager('select_and_send_terminals')
AgentRegistry.send_selection = delegate_to_manager('send_selection')
AgentRegistry.send = delegate_to_manager('send')
AgentRegistry.send_buffer_diagnostics = delegate_to_manager('send_buffer_diagnostics')
AgentRegistry.send_selection_diagnostics = delegate_to_manager('send_selection_diagnostics')

function AgentRegistry.select_manager()
  if #AgentRegistry.managers == 0 then
    vim.notify('No agent managers available', vim.log.levels.WARN)
    return
  end

  local items = vim
    .iter(AgentRegistry.managers)
    :enumerate()
    :map(function(i, manager)
      local is_current = manager == AgentRegistry.last_used_manager and ' (current)' or ''
      return {
        label = string.format('%d: %s%s', i, manager.opts.display_name, is_current),
        idx = i,
        manager = manager,
      }
    end)
    :totable()

  vim.ui.select(items, {
    prompt = 'Select Agent Manager:',
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice then
      AgentRegistry.last_used_manager = choice.manager
      vim.notify('Switched to ' .. choice.manager.opts.display_name, vim.log.levels.INFO)
    end
  end)
end

function AgentRegistry.setup_keymaps()
  if AgentRegistry._initialized then
    return
  end

  local prefix = '<leader>l'

  Util.setup_keymaps_and_commands(prefix, 'Agent', {
    toggle = function() AgentRegistry.toggle() end,
    send_current_buffer = function() AgentRegistry.send_current_buffer() end,
    select_and_send_buffers = function() AgentRegistry.select_and_send_buffers() end,
    select_and_send_terminals = function() AgentRegistry.select_and_send_terminals() end,
    select_and_send_files = function() AgentRegistry.select_and_send_files() end,
    send_selection = function() AgentRegistry.send_selection() end,
    create = function() AgentRegistry.create() end,
    select = function() AgentRegistry.select() end,
    next = function() AgentRegistry.next() end,
    prev = function() AgentRegistry.prev() end,
    close = function() AgentRegistry.close() end,
    send_buffer_diagnostics = function() AgentRegistry.send_buffer_diagnostics() end,
    send_selection_diagnostics = function() AgentRegistry.send_selection_diagnostics() end,
  })

  vim.keymap.set('n', prefix .. 'm', function() AgentRegistry.select_manager() end, { desc = 'Agent Selection' })
  vim.api.nvim_create_user_command('LatestAgentSelectManager', function() AgentRegistry.select_manager() end, {})

  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>l', group = 'llm', mode = { 'n', 'v' } } }, { notify = false })
  end

  AgentRegistry._initialized = true
end

return AgentRegistry
