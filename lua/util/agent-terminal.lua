---@class AgentTerminalsOpts
---@field display_name string Human-readable name (e.g., 'OpenCode')
---@field executable string Command to launch (e.g., 'opencode')
---@field filetype string Filetype to set on terminal buffer
---@field focus boolean
---@field insert boolean
---@field leader string Keymap prefix (e.g., '<leader>c') for setting up default keymaps
---@field split 'right'|'left'|'above'|'below'

---@class AgentTerminal
---@field display_name string
---@field executable string
---@field filetype string
---@field terminal_buf? integer
---@field terminal_job_id? integer
---@field private opts AgentTerminalsOpts options for the managed terminal
local AgentTerminal = {}
AgentTerminal.__index = AgentTerminal

---@class AgentTerminals
---@field private last_visited_agent AgentTerminal? last visited terminal instance
---@field private newline string newline character
---@field private agents AgentTerminal[] list of managed agents
---@field opts AgentTerminalsOpts options for the managed agents
local AgentTerminals = {
  last_visited_agent = nil,
  newline = ' \x0A ',
  agents = {},
  opts = {
    executable = 'agent-terminal',
    filetype = 'agent-terminal',
    display_name = 'Agent Terminal',
    leader = '<leader>a',
    split = 'right',
    focus = true,
    insert = true,
  },
}
AgentTerminals.__index = AgentTerminals

--- Get all non floating valid windows displaying the given buffer
---@param bufnr integer
---@return integer[] list of window IDs
local function buf_get_valid_wins(bufnr)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  return vim.tbl_filter(
    function(win)
      return vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_config(win).relative == ''
        and vim.api.nvim_win_get_buf(win) == bufnr
    end,
    wins
  )
end

---@param opts AgentTerminalsOpts options for the managed terminals
function AgentTerminals.new(opts)
  local self = setmetatable({
    last_visited_terminal = nil,
    terminals = {},
    opts = vim.tbl_deep_extend('force', AgentTerminals.opts, opts or {}),
  }, AgentTerminals)

  self:setup_commands_and_keymaps(opts)
  self:setup_autocmds()
  return self
end

--- Setup autocommands to track last visited terminal buffer.
---@private
function AgentTerminals:setup_autocmds()
  -- local pattern = '*' .. self.opts.filetype .. '*'
  -- vim.api.nvim_create_autocmd('BufEnter', {
  --   pattern = { pattern },
  --   callback = function(args)
  --     if vim.bo[args.buf].buftype == 'terminal' then
  --       local buf = args.buf
  --       local agent = vim.iter(self.agents):filter(function(agent) return agent.terminal_buf == buf end):next()
  --       if agent then
  --         self.last_visited_agent = agent
  --       else
  --         pcall(function() self:create(args.buf) end)
  --       end
  --     end
  --   end,
  -- })

  vim.api.nvim_create_autocmd('TermClose', {
    callback = function(args)
      ---@type AgentTerminal|nil
      local agent_to_remove = vim
        .iter(self.agents)
        :filter(function(agent) return agent.terminal_buf == args.buf end)
        :next()

      if agent_to_remove then
        self:remove(agent_to_remove)
      end
    end,
  })
end

--- Setup user command and keymaps with the given prefix.
---@private
---@param opts AgentTerminalsOpts terminal options
function AgentTerminals:setup_commands_and_keymaps(opts)
  local prefix = opts.leader
  local name = opts.display_name:gsub('%s+', '')
  vim.keymap.set('n', prefix .. 't', function() self:toggle() end, { desc = name .. ' Toggle' })
  vim.api.nvim_create_user_command(name .. 'Toggle', function() self:toggle() end, {})

  vim.keymap.set('n', prefix .. 'b', function() self:send_current_buffer() end, { desc = name .. ' Send Buffer' })
  vim.api.nvim_create_user_command(name .. 'SendBuffer', function() self:send_current_buffer() end, {})

  vim.keymap.set('n', prefix .. 'f', function() self:select_and_send_files() end, { desc = name .. ' Send Files' })
  vim.api.nvim_create_user_command(name .. 'SendFiles', function() self:select_and_send_files() end, {})

  vim.keymap.set('v', prefix .. 'e', function() self:send_selection() end, { desc = name .. ' Send Selection' })
  vim.api.nvim_create_user_command(name .. 'SendSelection', function() self:send_selection() end, { range = true })

  vim.keymap.set('n', prefix .. 'n', function() self:create() end, { desc = name .. ' New' })
  vim.api.nvim_create_user_command(name .. 'New', function() self:create() end, {})

  vim.keymap.set('n', prefix .. 's', function() self:select() end, { desc = name .. ' Select' })
  vim.api.nvim_create_user_command(name .. 'Select', function() self:select() end, {})

  vim.api.nvim_create_user_command(name .. 'Next', function() self:next() end, {})
  vim.api.nvim_create_user_command(name .. 'Prev', function() self:prev() end, {})

  vim.api.nvim_create_user_command(
    name .. 'DebugAgents',
    function() vim.notify(vim.inspect(self.agents), vim.log.levels.INFO) end,
    {}
  )
end

--- Focus the next/previous terminal by offset, wrapping around.
---@private
---@param offset integer
function AgentTerminals:focus_offset(offset)
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

function AgentTerminals:next() self:focus_offset(1) end
function AgentTerminals:prev() self:focus_offset(-1) end

--- First, hide all terminals if at least one is visible.
--- Otherwise, focus the last visited agent or the first existing one.
--- Finally, create a new terminal if none exist.
function AgentTerminals:toggle()
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

function AgentTerminals:hide_all()
  vim.iter(self.agents):each(function(agent)
    vim.iter(buf_get_valid_wins(agent.terminal_buf)):each(function(win) vim.api.nvim_win_hide(win) end)
  end)
end

--- Create the terminal buffer/window and start the agent process.
function AgentTerminals:create()
  -- Get first available window or create a new split
  local first_win_that_show_agent = self:get_current_agent_win()
    or vim
      .iter(self.agents)
      :map(function(agent) return buf_get_valid_wins(agent.terminal_buf) end)
      :filter(function(wins) return #wins > 0 end)
      :map(function(wins) return wins[1] end)
      :next()

  -- NOTE: Focus is required to open a new agent in an existing window without errors.
  if first_win_that_show_agent then
    vim.api.nvim_set_current_win(first_win_that_show_agent)
  end

  local agent = AgentTerminal.new(self.opts, nil, first_win_that_show_agent, nil)
  table.insert(self.agents, agent)
  self.last_visited_agent = agent

  self:update_agent_names()
end

--- Focus the current window if it contains an agent otherwise,
--- find the first available agent window that is not the target or create a new one.
---@param agent_to_focus AgentTerminal
function AgentTerminals:switch_focus(agent_to_focus)
  local win_to_focus = self:get_current_agent_win()
    or vim
      .iter(self.agents)
      :filter(function(agent) return agent.terminal_buf ~= agent_to_focus.terminal_buf end)
      :map(function(agent) return buf_get_valid_wins(agent.terminal_buf) end)
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

function AgentTerminals:get_current_agent_win()
  local current_buf = vim.api.nvim_get_current_buf()
  return vim.tbl_contains(
    self.agents,
    function(agent) return agent.terminal_buf == current_buf end,
    { predicate = true }
  ) and vim.api.nvim_get_current_win() or nil
end

---@param agent_to_remove AgentTerminal
function AgentTerminals:remove(agent_to_remove)
  self.agents = vim.tbl_filter(
    function(agent) return agent.terminal_buf ~= agent_to_remove.terminal_buf end,
    self.agents
  )
  if self.last_visited_agent and self.last_visited_agent.terminal_buf == agent_to_remove.terminal_buf then
    self.last_visited_agent = self.agents[#self.agents] or nil
  end

  self:update_agent_names()
end

--- Update agents window filename as 'Name <index>/<total>'
function AgentTerminals:update_agent_names()
  local nb_agents = #self.agents
  local title = self.opts.display_name
  vim.iter(self.agents):enumerate():each(function(i, agent)
    if agent:buffer_valid() then
      local name = nb_agents > 1 and string.format('%s %d╱%d', title, i, nb_agents) or title
      vim.api.nvim_buf_set_name(agent.terminal_buf, name)
    end
  end)
end

function AgentTerminals:hide_other_agents(current_agent)
  vim
    .iter(self.agents)
    :filter(
      ---@param other AgentTerminal
      function(other) return other.terminal_buf ~= current_agent.terminal_buf end
    )
    :each(
      ---@param agent AgentTerminal
      function(agent)
        vim.iter(buf_get_valid_wins(agent.terminal_buf)):each(function(win) vim.api.nvim_win_hide(win) end)
      end
    )
end

--- Select a terminal by index and update last_visited_terminal
function AgentTerminals:select()
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
      ---@param agent AgentTerminal
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
                ---@param terminal AgentTerminal
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

--- Create a new terminal controller for a specific external agent/executable.
---@param opts AgentTerminalsOpts options for the managed terminal
---@param buf? integer existing buffer number to attach to
---@param win? integer existing window number to attach to
---@param job_id? integer existing buffer number to attach to
---@return AgentTerminal
function AgentTerminal.new(opts, buf, win, job_id)
  local self = setmetatable({
    display_name = opts.display_name,
    executable = opts.executable,
    filetype = opts.filetype,
    terminal_buf = buf or vim.api.nvim_create_buf(false, false),
    terminal_job_id = job_id,
    opts = opts,
  }, AgentTerminal)

  vim.api.nvim_set_option_value('filetype', self.filetype, { buf = self.terminal_buf })

  if not win then
    vim.api.nvim_open_win(self.terminal_buf, opts.focus, { split = opts.split or 'right', win = 0 })
  else
    vim.api.nvim_win_set_buf(win, self.terminal_buf)
  end

  if not job_id then
    self.terminal_job_id = vim.fn.jobstart(self.executable, {
      term = true,
      on_exit = function()
        -- Clean up the terminal buffer and job ID
        self.terminal_job_id = nil
        if self.terminal_buf and vim.api.nvim_buf_is_valid(self.terminal_buf) then
          vim.api.nvim_buf_delete(self.terminal_buf, { force = true })
          self.terminal_buf = nil
        end
      end,
    })
  end

  return self
end

function AgentTerminal:buffer_valid() return self.terminal_buf and vim.api.nvim_buf_is_valid(self.terminal_buf) end
function AgentTerminal:is_open() return #buf_get_valid_wins(self.terminal_buf) > 0 end
function AgentTerminal:job_valid() return self.terminal_job_id and vim.fn.jobwait({ self.terminal_job_id }, 0)[1] == -1 end

function AgentTerminal:focus()
  if not self:buffer_valid() then
    vim.notify('Terminal buffer is not valid', vim.log.levels.ERROR)
    return
  end

  local wins = buf_get_valid_wins(self.terminal_buf)
  if #wins > 0 then
    vim.api.nvim_set_current_win(wins[1])
  else
    vim.api.nvim_open_win(self.terminal_buf, self.opts.focus, { split = self.opts.split or 'right', win = 0 })
  end

  if self.opts.insert then
    vim.cmd('startinsert')
  end
end

function AgentTerminal:toggle()
  local wins = buf_get_valid_wins(self.terminal_buf)
  if #wins > 0 then
    vim.iter(wins):each(function(win) vim.api.nvim_win_hide(win) end)
  else
    self:focus()
  end
end

---@param content string
function AgentTerminal:send(content)
  if self:job_valid() then
    vim.api.nvim_chan_send(self.terminal_job_id, content)
  end
end

--- Prompt, then send the current buffer's file and the user input to the terminal.
function AgentTerminals:send_current_buffer()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
  end

  if agent then
    local file = vim.fn.expand('%:p')
    vim.ui.input({ prompt = 'Ask file:' }, function(input)
      if input ~= nil then
        agent:send(file .. self.newline .. input .. self.newline)
      end
    end)
  end
end

--- Open a file picker and send selected files to the terminal.
function AgentTerminals:select_and_send_files()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end

  if agent then
    local snacks = require('snacks')
    snacks.picker.files({
      title = 'Select Files to Send to ' .. (agent.display_name or 'Agent'),
      confirm = function(picker)
        local files = picker:selected()
        local files_text = vim.iter(files):map(function(f) return f.file end):join(self.newline) .. self.newline
        agent:send(files_text)
        picker:close()
      end,
    })
  else
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
  end
end

--- Send the current visual selection as a fenced code block, then prompt for a question.
function AgentTerminals:send_selection()
  local agent = self.last_visited_agent
  if not agent then
    vim.notify('No agent terminal selected', vim.log.levels.WARN)
    return
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
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

--- Send current buffer's diagnostics to the terminal with context.
function AgentTerminals:send_buffer_diagnostics()
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

  -- Sort diagnostics by line number
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
    local line_num = diagnostic.lnum + 1 -- Convert from 0-based to 1-based
    local col_num = diagnostic.col + 1

    diagnostic_text = diagnostic_text
      .. string.format('[%s] Line %d:%d - %s%s', severity, line_num, col_num, diagnostic.message, self.newline)
  end

  agent:send(diagnostic_text .. self.newline .. '```' .. self.newline)
end

return AgentTerminals
