local Agent = require('util.agents.agent')
local AgentRegistry = require('util.agents.agent-registry')
local Util = require('util.agents.util')

---@class AgentManager
---@field private last_visited_agent Agent? last visited terminal instance
---@field private newline string newline character
---@field private agents Agent[] list of managed agents
---@field opts AgentsOpts options for the managed agents
local AgentManager = {}
AgentManager.__index = AgentManager

---@param opts AgentsOpts options for the managed terminals
function AgentManager.new(opts)
  local agent_manager = setmetatable({
    last_visited_terminal = nil,
    newline = ' \x0A ',
    agents = {},
    opts = vim.tbl_deep_extend('force', {
      executable = 'agent-terminal',
      filetype = 'agent-terminal',
      display_name = 'Agent Terminal',
      leader = '<leader>a',
      split = 'right',
      focus = true,
      insert = true,
    }, opts or {}),
  }, AgentManager)

  agent_manager.opts.on_focus = function(agent)
    agent_manager.last_visited_agent = agent
    AgentRegistry.update_last_used(agent_manager)
  end

  agent_manager:setup_commands_and_keymaps(agent_manager.opts)
  agent_manager:setup_autocmds()

  AgentRegistry.register(agent_manager)
  AgentRegistry.setup_keymaps()

  return agent_manager
end

--- Setup autocommands to track last visited terminal buffer.
---@private
function AgentManager:setup_autocmds()
  vim.api.nvim_create_autocmd('TermClose', {
    callback = function(args)
      ---@type Agent|nil
      local agent_to_remove = vim
        .iter(self.agents)
        :filter(function(agent) return agent.terminal_buf == args.buf end)
        :next()

      if agent_to_remove then
        self:remove(agent_to_remove)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    callback = function(args)
      ---@type Agent|nil
      local entered_agent = vim
        .iter(self.agents)
        :filter(function(agent) return agent.terminal_buf == args.buf end)
        :next()

      if entered_agent and entered_agent:buffer_valid() then
        self.last_visited_agent = entered_agent
        AgentRegistry.update_last_used(self)
      end
    end,
  })
end

--- Setup user command and keymaps with the given prefix.
---@private
---@param opts AgentsOpts terminal options
function AgentManager:setup_commands_and_keymaps(opts)
  local prefix = opts.leader
  local name = opts.display_name:gsub('%s+', '')

  Util.setup_keymaps_and_commands(prefix, name, {
    toggle = function() self:toggle() end,
    send_current_buffer = function() self:send_current_buffer() end,
    select_and_send_buffers = function() self:select_and_send_buffers() end,
    select_and_send_terminals = function() self:select_and_send_terminals() end,
    select_and_send_files = function() self:select_and_send_files() end,
    send_selection = function() self:send_selection() end,
    create = function() self:create() end,
    select = function() self:select() end,
    next = function() self:next() end,
    prev = function() self:prev() end,
    close = function() self:close() end,
    send_buffer_diagnostics = function() self:send_buffer_diagnostics() end,
    send_selection_diagnostics = function() self:send_selection_diagnostics() end,
  })

  vim.api.nvim_create_user_command(
    name .. 'DebugAgents',
    function() vim.notify(vim.inspect(self.agents), vim.log.levels.INFO) end,
    {}
  )
end

--- Focus the next/previous terminal by offset, wrapping around.
---@private
---@param offset integer
function AgentManager:focus_offset(offset)
  if #self.agents == 0 then
    vim.notify('No agent terminals available', vim.log.levels.WARN)
    return
  end

  if #self.agents <= 1 then
    return
  end

  local current_idx = vim
    .iter(self.agents)
    :enumerate()
    :filter(function(_, agent) return agent == self.last_visited_agent end)
    :map(function(i) return i end)
    :next()

  local offset_idx = ((current_idx - 1 + offset) % #self.agents) + 1
  local agent_to_focus = self.agents[offset_idx]

  if agent_to_focus then
    self:switch_focus(agent_to_focus)
  end
end

function AgentManager:next() self:focus_offset(1) end
function AgentManager:prev() self:focus_offset(-1) end

--- First, hide all terminals if at least one is visible.
--- Otherwise, focus the last visited agent or the first existing one.
--- Finally, create a new terminal if none exist.
function AgentManager:toggle()
  AgentRegistry.update_last_used(self)
  local any_open = vim.iter(self.agents):any(function(agent) return agent:is_open() end)
  if any_open then
    self:hide_all()
  elseif self.last_visited_agent then
    self.last_visited_agent:focus()
  elseif #self.agents > 0 then
    self.agents[1]:focus()
    self.last_visited_agent = self.agents[1]
  else
    self:create()
  end
end

function AgentManager:hide_all()
  vim.iter(self.agents):each(function(agent)
    vim.iter(Util.buf_get_valid_wins(agent.terminal_buf)):each(function(win) vim.api.nvim_win_hide(win) end)
  end)
end

--- Create the terminal buffer/window and start the agent process.
function AgentManager:create()
  AgentRegistry.update_last_used(self)
  -- Get first available window or create a new split
  local first_win_that_show_agent = self:get_current_agent_win()
    or vim
      .iter(self.agents)
      :map(function(agent) return Util.buf_get_valid_wins(agent.terminal_buf) end)
      :filter(function(wins) return #wins > 0 end)
      :map(function(wins) return wins[1] end)
      :next()

  -- NOTE: Focus is required to open a new agent in an existing window without errors.
  if first_win_that_show_agent then
    vim.api.nvim_set_current_win(first_win_that_show_agent)
  end

  local agent = Agent.new(self.opts, nil, first_win_that_show_agent, nil)
  table.insert(self.agents, agent)
  self.last_visited_agent = agent

  self:update_agent_names()
end

--- Focus the current window if it contains an agent otherwise,
--- find the first available agent window that is not the target or create a new one.
---@param agent_to_focus Agent
function AgentManager:switch_focus(agent_to_focus)
  local win_to_focus = self:get_current_agent_win()
    or vim
      .iter(self.agents)
      :filter(function(agent) return agent.terminal_buf ~= agent_to_focus.terminal_buf end)
      :map(function(agent) return Util.buf_get_valid_wins(agent.terminal_buf) end)
      :filter(function(wins) return #wins > 0 end)
      :map(function(wins) return wins[1] end)
      :next()

  if win_to_focus then
    vim.api.nvim_win_set_buf(win_to_focus, agent_to_focus.terminal_buf)
    self.last_visited_agent = agent_to_focus
  else
    agent_to_focus:focus()
    self.last_visited_agent = agent_to_focus
  end
end

function AgentManager:get_current_agent_win()
  local current_buf = vim.api.nvim_get_current_buf()
  return vim.tbl_contains(
    self.agents,
    function(agent) return agent.terminal_buf == current_buf end,
    { predicate = true }
  ) and vim.api.nvim_get_current_win() or nil
end

---@param agent_to_remove Agent
function AgentManager:remove(agent_to_remove)
  self.agents = vim.tbl_filter(
    function(agent) return agent.terminal_buf ~= agent_to_remove.terminal_buf end,
    self.agents
  )
  if self.last_visited_agent and self.last_visited_agent.terminal_buf == agent_to_remove.terminal_buf then
    self.last_visited_agent = self.agents[#self.agents] or nil
  end

  self:update_agent_names()
end

--- Close the currently focused agent terminal
function AgentManager:close()
  local buf = vim.api.nvim_get_current_buf()
  local agent_to_close = vim.iter(self.agents):filter(function(agent) return agent.terminal_buf == buf end):next()

  if agent_to_close then
    -- switch the window to the previous agent if available
    self:prev()

    -- remove the buffer of the current agent, should trigger TermClose autocmd
    vim.api.nvim_buf_delete(agent_to_close.terminal_buf, { force = true })
  end
end

--- Update agents window filename as 'Name <index>/<total>'
function AgentManager:update_agent_names()
  local nb_agents = #self.agents
  local title = self.opts.display_name
  vim.iter(self.agents):enumerate():each(function(i, agent)
    if agent:buffer_valid() then
      local name = nb_agents > 1 and string.format('%s %d╱%d', title, i, nb_agents) or title
      vim.api.nvim_buf_set_name(agent.terminal_buf, name)
    end
  end)
end

function AgentManager:hide_other_agents(current_agent)
  vim
    .iter(self.agents)
    :filter(
      ---@param other Agent
      function(other) return other.terminal_buf ~= current_agent.terminal_buf end
    )
    :each(
      ---@param agent Agent
      function(agent)
        vim.iter(Util.buf_get_valid_wins(agent.terminal_buf)):each(function(win) vim.api.nvim_win_hide(win) end)
      end
    )
end

--- Select a terminal by index and update last_visited_terminal
function AgentManager:select()
  AgentRegistry.update_last_used(self)
  local items = {}
  for i, agent in ipairs(self.agents) do
    table.insert(items, {
      label = string.format('%d: %s (buf %s)', i, agent.display_name or 'Agent', tostring(agent.terminal_buf)),
      idx = i,
      term = agent,
    })
  end

  local items = vim
    .iter(self.agents)
    :enumerate()
    :map(
      ---@param i integer
      ---@param agent Agent
      function(i, agent)
        local last_visited = agent == self.last_visited_agent and ' (current)' or ''
        return {
          label = string.format(
            '%d: %s (buf %s)',
            i,
            agent.display_name .. 'Agent' .. last_visited,
            tostring(agent.terminal_buf)
          ),
          idx = i,
          term = agent,
        }
      end
    )
    :totable()

  if #items == 0 then
    vim.notify('No agent terminals available', vim.log.levels.WARN)
    return
  end

  Snacks.picker.buffers({
    title = 'Terminals',
    hidden = true,
    sort_lastused = true,
    source = 'agent_terminals',
    layout = { preset = 'telescope_vertical' },
    filter = {
      filter =
        ---@param item snacks.picker.finder.Item
        function(item)
          return item.buf
              and vim.tbl_contains(
                self.agents,
                ---@param terminal Agent
                function(terminal) return terminal.terminal_buf == item.buf end,
                { predicate = true } or false
              )
            or false
        end,
    },
    confirm = function(picker)
      local selected = picker:selected({ fallback = true })[1]
      picker:close()
      if selected then
        local agent = vim.iter(self.agents):filter(function(agent) return agent.terminal_buf == selected.buf end):next()
        if agent then
          self:switch_focus(agent)
        end
      end
    end,
  })
end

--- Prompt, then send the current buffer's file and the user input to the terminal.
function AgentManager:send_current_buffer()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end
  AgentRegistry.update_last_used(self)

  local file = vim.fn.expand('%:p')
  vim.ui.input({ prompt = 'Ask file:' }, function(input)
    if input ~= nil then
      agent:send('File: ' .. self.newline .. file .. self.newline .. input .. self.newline)
    end
  end)
end

--- Open a file picker and send selected files to the terminal.
function AgentManager:select_and_send_files()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end
  AgentRegistry.update_last_used(self)

  local snacks = require('snacks')
  snacks.picker.files({
    title = 'Select Files to Send to ' .. (agent.display_name or 'Agent'),
    confirm = function(picker)
      local files = picker:selected()
      local files_text = vim.iter(files):map(function(f) return ' ' .. f.file end):join(self.newline) .. self.newline
      agent:send('files: ' .. self.newline .. ' ' .. files_text)
      picker:close()
    end,
  })
end

--- Open a buffer picker and send selected buffers to the terminal.
function AgentManager:select_and_send_buffers()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end
  AgentRegistry.update_last_used(self)

  local snacks = require('snacks')
  snacks.picker.buffers({
    title = 'Select Buffers to Send to ' .. (agent.display_name or 'Agent'),
    confirm = function(picker)
      local buffers = picker:selected()
      local buffers_text = vim.iter(buffers):map(function(b) return b.buf end):join(self.newline) .. self.newline
      agent:send('buffers: ' .. self.newline .. ' ' .. buffers_text)
      picker:close()
    end,
  })
end

--- Open a terminal picker and send selected terminals to the terminal
--- Send the content of the terminal buffers
function AgentManager:select_and_send_terminals()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end
  AgentRegistry.update_last_used(self)

  local snacks = require('snacks')
  snacks.picker.buffers({
    title = 'Select Terminals to Send to ' .. (agent.display_name or 'Agent'),
    hidden = true,
    sort_lastused = true,
    filter = {
      filter =
        ---@param item snacks.picker.finder.Item
        function(item)
          return item.buf
            and vim.api.nvim_get_option_value('buftype', { buf = item.buf }) == 'terminal'
            and item.buf ~= agent.terminal_buf
        end,
    },
    confirm = function(picker)
      local terminals = picker:selected()
      local terminals_content = vim
        .iter(terminals)
        :map(function(t)
          local lines = vim.api.nvim_buf_get_lines(t.buf, 0, -1, false)
          return table.concat(lines, '\n')
        end)
        :join('\n\n')

      agent:send(terminals_content .. self.newline)
      picker:close()
    end,
  })
end

--- Send the current visual selection as a fenced code block, then prompt for a question.
function AgentManager:send_selection()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end
  AgentRegistry.update_last_used(self)

  local start_line, end_line = Util.get_visual_selection_range()
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local text = table.concat(lines, self.newline)

  local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  local formatted_text = self.newline
    .. ' ```'
    .. filetype
    .. self.newline
    .. text
    .. self.newline
    .. '```'
    .. self.newline

  vim.ui.input({ prompt = 'Ask selection:' }, function(input)
    if input ~= nil then
      agent:send(
        'Here is a code snippet from '
          .. vim.fn.expand('%:p')
          .. ':'
          .. self.newline
          .. formatted_text
          .. self.newline
          .. input
          .. self.newline
      )
    end
  end)
end

function AgentManager:send(...)
  AgentRegistry.update_last_used(self)
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end

  agent:send(...)
end

--- Send current buffer's diagnostics to the terminal with context.
function AgentManager:send_buffer_diagnostics()
  AgentRegistry.update_last_used(self)
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(current_buf)

  if #diagnostics == 0 then
    vim.notify('No diagnostics found in current buffer', vim.log.levels.INFO)
    return
  end

  table.sort(diagnostics, function(a, b) return a.lnum < b.lnum end)

  local diagnostic_text = self.newline
    .. '```'
    .. self.newline
    .. 'Diagnostics for '
    .. vim.fn.expand('%:p')
    .. ':'
    .. self.newline
    .. self.newline

  for _, diagnostic in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diagnostic.severity] or 'UNKNOWN'
    local line_num = diagnostic.lnum + 1
    local col_num = diagnostic.col + 1

    diagnostic_text = diagnostic_text
      .. string.format('[%s] Line %d:%d - %s%s', severity, line_num, col_num, diagnostic.message, self.newline)
  end

  agent:send(diagnostic_text .. self.newline .. '```' .. self.newline)
end

function AgentManager:send_selection_diagnostics()
  AgentRegistry.update_last_used(self)
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end

  local start_line, end_line = Util.get_visual_selection_range()

  local current_buf = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(current_buf)

  diagnostics = vim.tbl_filter(function(d) return d.lnum >= start_line and d.lnum < end_line end, diagnostics)

  if #diagnostics == 0 then
    vim.notify('No diagnostics found in selected lines', vim.log.levels.INFO)
    return
  end

  table.sort(diagnostics, function(a, b) return a.lnum < b.lnum end)

  local diagnostic_text = self.newline
    .. '```'
    .. self.newline
    .. 'Diagnostics for '
    .. vim.fn.expand('%:p')
    .. ' (lines '
    .. (start_line + 1)
    .. '-'
    .. end_line
    .. '):'
    .. self.newline
    .. self.newline

  for _, diagnostic in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diagnostic.severity] or 'UNKNOWN'
    local line_num = diagnostic.lnum + 1
    local col_num = diagnostic.col + 1

    diagnostic_text = diagnostic_text
      .. string.format('[%s] Line %d:%d - %s%s', severity, line_num, col_num, diagnostic.message, self.newline)
  end

  agent:send(diagnostic_text .. self.newline .. '```' .. self.newline)
end

return AgentManager
