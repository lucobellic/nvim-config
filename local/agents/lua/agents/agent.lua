local Util = require('agents.util')

---@class AgentsOpts
---@field display_name string Human-readable name (e.g., 'OpenCode')
---@field executable string|string[] Command to launch (e.g., 'opencode')
---@field env? table<string, string> Environment overrides for the terminal
---@field filetype string Filetype to set on terminal buffer
---@field focus boolean
---@field insert boolean
---@field leader string Keymap prefix (e.g., '<leader>c') for setting up default keymaps
---@field split 'right'|'left'|'above'|'below'
---@field on_focus? fun(agent: Agent) Callback when agent is focused

---@class Agent
---@field display_name string
---@field executable string|string[]
---@field filetype string
---@field terminal_buf? integer
---@field terminal_job_id? integer
---@field private opts AgentsOpts options for the managed terminal
---@field private on_focus? fun(agent: Agent) Callback when agent is focused
local Agent = {}
Agent.__index = Agent

---@public
---@param win integer
function Agent:configure_window(win)
  vim.api.nvim_set_option_value('list', false, { win = win, scope = 'local' })
  -- Keep visual selections at the right edge from scrolling the TUI horizontally.
  vim.api.nvim_set_option_value('wrap', true, { win = win, scope = 'local' })
end

--- Create a new terminal controller for a specific external agent/executable.
--- Does NOT open the window or start the terminal job; call `agent:start(win)` afterward.
---@param opts AgentsOpts options for the managed terminal
---@param buf? integer existing buffer number to attach to
---@param win? integer existing window number to attach to
---@param job_id? integer existing buffer number to attach to
---@return Agent
---@public
function Agent.new(opts, buf, win, job_id)
  local self = setmetatable({
    display_name = opts.display_name,
    executable = opts.executable,
    filetype = opts.filetype,
    terminal_buf = buf or vim.api.nvim_create_buf(false, false),
    terminal_job_id = job_id,
    opts = opts,
    on_focus = opts.on_focus,
  }, Agent)

  if job_id then
    vim.api.nvim_set_option_value('filetype', self.filetype, { buf = self.terminal_buf })
    if win then
      vim.api.nvim_win_set_buf(win, self.terminal_buf)
      self:configure_window(win)
    end
  end

  return self
end

--- Open the terminal window and start the job process.
--- Must be called after the agent has been registered in AgentManager.agents.
---@param win? integer existing window number to attach to
---@public
function Agent:start(win)
  vim.api.nvim_set_option_value('filetype', self.filetype, { buf = self.terminal_buf })

  if not win then
    win = vim.api.nvim_open_win(self.terminal_buf, self.opts.focus, { split = self.opts.split or 'right', win = 0 })
  else
    vim.api.nvim_win_set_buf(win, self.terminal_buf)
  end

  if not self.terminal_job_id then
    self.terminal_job_id = vim.fn.jobstart(self.executable, {
      term = true,
      env = self.opts.env,
      on_exit = function()
        self.terminal_job_id = nil
        if self.terminal_buf and vim.api.nvim_buf_is_valid(self.terminal_buf) then
          vim.api.nvim_buf_delete(self.terminal_buf, { force = true })
          self.terminal_buf = nil
        end
      end,
    })
  end
  -- Terminal defaults and TermOpen handlers can disable wrapping during jobstart.
  self:configure_window(win)
end

function Agent:buffer_valid() return self.terminal_buf and vim.api.nvim_buf_is_valid(self.terminal_buf) end
function Agent:is_open() return #Util.buf_get_valid_wins(self.terminal_buf) > 0 end
function Agent:job_valid() return self.terminal_job_id and vim.fn.jobwait({ self.terminal_job_id }, 0)[1] == -1 end

---@public
function Agent:focus()
  if not self:buffer_valid() then
    vim.notify('Terminal buffer is not valid', vim.log.levels.ERROR)
    return
  end

  local wins = Util.buf_get_valid_wins(self.terminal_buf)
  local win = wins[1]
  if #wins > 0 then
    vim.api.nvim_set_current_win(win)
  else
    win = vim.api.nvim_open_win(self.terminal_buf, self.opts.focus, { split = self.opts.split or 'right', win = 0 })
  end
  self:configure_window(win)

  if self.opts.insert then
    vim.cmd('startinsert')
  end

  if self.on_focus then
    self.on_focus(self)
  end
end

function Agent:toggle()
  local wins = Util.buf_get_valid_wins(self.terminal_buf)
  if #wins > 0 then
    vim.iter(wins):each(function(win) vim.api.nvim_win_hide(win) end)
  else
    self:focus()
  end
end

function Agent:send(content)
  if self:job_valid() then
    vim.api.nvim_chan_send(self.terminal_job_id, '\x1b[200~' .. content .. '\x1b[201~')
  end
end

function Agent:send_enter()
  if self:job_valid() then
    vim.api.nvim_chan_send(self.terminal_job_id, '\r')
  end
end

return Agent
