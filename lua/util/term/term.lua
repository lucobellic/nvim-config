---@class TermOpts
---@field width? number Window width (0.0-1.0 or absolute)
---@field height? number Window height (0.0-1.0 or absolute)
---@field border? string Border style ('auto', 'none', 'single', 'solid')
---@field zindex? number Z-index for floating window
---@field title? string Display title
---@field start_insert? boolean Whether to start in insert mode (default: false)
---@field on_open? fun(term: Term) Callback when terminal opens
---@field on_close? fun(term: Term) Callback when terminal closes
---@field on_exit? fun(term: Term, code: number) Callback when job exits

---@class Term
---@field name string Terminal identifier (e.g., 'default', 'lazygit')
---@field title string Display title
---@field cmd string|string[] Command to execute
---@field bufnr integer Terminal buffer number
---@field job_id? integer Terminal job ID
---@field index integer Terminal index (1-based)
---@field opts TermOpts Terminal configuration options
---@field private _created_at number Timestamp when created
local Term = {}
Term.__index = Term

--- Create a new terminal instance
---@param name string Terminal identifier
---@param cmd string|string[] Command to execute
---@param opts? TermOpts Terminal options
---@return Term
function Term.new(name, cmd, opts)
  opts = opts or {}

  local bufnr = vim.api.nvim_create_buf(false, true) -- unlisted, scratch buffer

  local self = setmetatable({
    name = name,
    title = opts.title or name:gsub('^%l', string.upper),
    cmd = cmd,
    bufnr = bufnr,
    job_id = nil,
    index = 0, -- Will be set by TermManager
    opts = opts,
    _created_at = os.time(),
  }, Term)

  -- Set buffer options (buftype will be set by termopen)
  vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = bufnr })
  vim.api.nvim_set_option_value('filetype', 'term', { buf = bufnr })

  -- Set buffer name
  local buf_name = string.format('term://%s#%d', name, bufnr)
  pcall(vim.api.nvim_buf_set_name, bufnr, buf_name)

  return self
end

--- Start the terminal job if not already running
---@return boolean success
function Term:start()
  if self:is_job_running() then
    return true
  end

  if not self:is_valid() then
    return false
  end

  local on_exit = self.opts.on_exit

  -- Need to be in the buffer to start the terminal
  local current_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_current_buf(self.bufnr)

  -- Build environment variables to prevent nested nvim (floaterm-style)
  local env = vim.fn.environ()

  -- Ensure TERM is set (required by tools like lazygit)
  -- Inherit from parent if available, otherwise use a sensible default
  if not env.TERM or env.TERM == '' then
    env.TERM = vim.env.TERM or 'xterm-256color'
  end

  -- Set NVIM to the server address so tools can connect back
  local servername = vim.v.servername
  if servername and servername ~= '' then
    env.NVIM = servername
    -- Use the editor wrapper script that mimics floaterm's behavior
    local wrapper_path = vim.fn.stdpath('config') .. '/lua/util/term/editor-wrapper.sh'
    env.GIT_EDITOR = wrapper_path
    env.EDITOR = wrapper_path
    env.VISUAL = wrapper_path
  end

  ---@diagnostic disable-next-line: deprecated
  self.job_id = vim.fn.termopen(self.cmd, {
    env = env,
    on_exit = function(_, code)
      self.job_id = nil
      if on_exit then
        on_exit(self, code)
      end
    end,
  })

  -- Ensure buftype is set to terminal
  if self:is_valid() then
    vim.api.nvim_set_option_value('buftype', 'terminal', { buf = self.bufnr })
  end

  -- Restore previous buffer
  if vim.api.nvim_buf_is_valid(current_buf) then
    vim.api.nvim_set_current_buf(current_buf)
  end

  return self.job_id ~= nil and self.job_id > 0
end

--- Check if buffer is valid
---@return boolean
function Term:is_valid() return self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) end

--- Check if terminal job is running
---@return boolean
function Term:is_job_running()
  if not self.job_id then
    return false
  end
  local result = vim.fn.jobwait({ self.job_id }, 0)
  return result[1] == -1
end

--- Kill terminal job and delete buffer
function Term:kill()
  if self.opts.on_close then
    self.opts.on_close(self)
  end

  if self.job_id and self:is_job_running() then
    vim.fn.jobstop(self.job_id)
  end
  self.job_id = nil

  if self:is_valid() then
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
  end
end

--- Update terminal dimensions (stored in opts)
---@param width number
---@param height number
function Term:resize(width, height)
  self.opts.width = width
  self.opts.height = height
end

return Term
