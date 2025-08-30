local Util = require('util.agents.util')

---@class AgentsOpts
---@field display_name string Human-readable name (e.g., 'OpenCode')
---@field executable string Command to launch (e.g., 'opencode')
---@field filetype string Filetype to set on terminal buffer
---@field focus boolean
---@field insert boolean
---@field leader string Keymap prefix (e.g., '<leader>c') for setting up default keymaps
---@field split 'right'|'left'|'above'|'below'

---@class Agent
---@field display_name string
---@field executable string
---@field filetype string
---@field terminal_buf? integer
---@field terminal_job_id? integer
---@field private opts AgentsOpts options for the managed terminal
local Agent = {}
Agent.__index = Agent

--- Create a new terminal controller for a specific external agent/executable.
---@param opts AgentsOpts options for the managed terminal
---@param buf? integer existing buffer number to attach to
---@param win? integer existing window number to attach to
---@param job_id? integer existing buffer number to attach to
---@return Agent
function Agent.new(opts, buf, win, job_id)
  local self = setmetatable({
    display_name = opts.display_name,
    executable = opts.executable,
    filetype = opts.filetype,
    terminal_buf = buf or vim.api.nvim_create_buf(false, false),
    terminal_job_id = job_id,
    opts = opts,
  }, Agent)

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

function Agent:buffer_valid() return self.terminal_buf and vim.api.nvim_buf_is_valid(self.terminal_buf) end
function Agent:is_open() return #Util.buf_get_valid_wins(self.terminal_buf) > 0 end
function Agent:job_valid() return self.terminal_job_id and vim.fn.jobwait({ self.terminal_job_id }, 0)[1] == -1 end

function Agent:focus()
  if not self:buffer_valid() then
    vim.notify('Terminal buffer is not valid', vim.log.levels.ERROR)
    return
  end

  local wins = Util.buf_get_valid_wins(self.terminal_buf)
  if #wins > 0 then
    vim.api.nvim_set_current_win(wins[1])
  else
    vim.api.nvim_open_win(self.terminal_buf, self.opts.focus, { split = self.opts.split or 'right', win = 0 })
  end

  if self.opts.insert then
    vim.cmd('startinsert')
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

---@param content string
function Agent:send(content)
  if self:job_valid() then
    vim.api.nvim_chan_send(self.terminal_job_id, content)
  end
end

return Agent
