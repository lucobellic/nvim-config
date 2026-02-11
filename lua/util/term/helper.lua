local Term = require('util.term.term')
local config = require('util.term.config')

local M = {}

--- Check if popup is currently visible and valid
---@param core TermCore Core module reference
---@return boolean
function M.is_popup_visible(core)
  return core.popup ~= nil and core.popup.winid ~= nil and vim.api.nvim_win_is_valid(core.popup.winid)
end

--- Find terminal by name
---@param terminals Term[] List of terminal instances
---@param name string
---@return Term?
function M.find_terminal_by_name(terminals, name)
  return vim.iter(terminals):filter(function(t) return t.name == name end):next()
end

--- Get dimensions from terminal opts or config defaults
---@param term_opts? TermOpts
---@return number width, number height
function M.get_dimensions(term_opts)
  local width = (term_opts and term_opts.width) or config.get_default_width()
  local height = (term_opts and term_opts.height) or config.get_default_height()
  return width, height
end

--- Configure window options for terminal buffer display
---@param winid integer Window ID
---@param bufnr integer Buffer number
---@return boolean success Whether the buffer was successfully set
function M.setup_window_buffer(winid, bufnr)
  if not vim.api.nvim_win_is_valid(winid) or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  vim.api.nvim_win_set_buf(winid, bufnr)
  vim.api.nvim_set_option_value('sidescrolloff', 0, { win = winid })
  vim.api.nvim_set_option_value('signcolumn', 'no', { win = winid })
  vim.api.nvim_set_option_value('wrap', true, { win = winid })
  vim.api.nvim_set_option_value('list', false, { win = winid })
  return true
end

--- Wrap user on_exit callback with cleanup logic
---@param opts TermOpts
---@param name string Terminal name for cleanup
---@param remove_fn function Function to call for removing terminal
---@return TermOpts opts Modified options with wrapped callback
function M.wrap_on_exit(opts, name, remove_fn)
  local user_on_exit = opts.on_exit
  opts.on_exit = function(term, code)
    if user_on_exit then
      user_on_exit(term, code)
    end
    -- Remove terminal on normal exit to allow fresh creation next time
    if code == 0 then
      vim.schedule(function() remove_fn(name) end)
    end
  end
  return opts
end

--- Generate unique terminal name
---@return string
function M.generate_unique_name() return 'Terminal ' .. tostring(vim.uv.hrtime()) end

--- Create a terminal instance from existing buffer
---@param bufnr integer Existing terminal buffer number
---@param opts? TermOpts Terminal options
---@return Term? term The created terminal or nil if invalid
function M.create_term_from_buffer(bufnr, opts)
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })

  if buftype ~= 'terminal' then
    vim.notify('Buffer ' .. bufnr .. ' is not a terminal buffer', vim.log.levels.ERROR)
    return nil
  end

  -- Create a term object from existing buffer
  local name = M.generate_unique_name()
  opts = vim.tbl_deep_extend('force', config.get().defaults, opts or {})

  -- Create a Term-like object without creating new buffer or starting job
  local term = setmetatable({
    name = name,
    title = opts.title or name:gsub('^%l', string.upper),
    cmd = '', -- No command for existing buffer
    bufnr = bufnr,
    job_id = vim.b[bufnr].terminal_job_id, -- Get existing job_id from buffer
    index = 0, -- Will be set by caller
    opts = opts,
    _created_at = os.time(),
    _from_existing = true, -- Flag to indicate this is from existing buffer
  }, { __index = Term })

  -- Override methods for existing terminal buffers
  term.start = function(_)
    -- Already running, no need to start
    return true
  end

  term.kill = function(self)
    if self.opts.on_close then
      self.opts.on_close(self)
    end
    -- Don't kill job or delete buffer for existing terminals
    self.job_id = nil
  end

  return term
end

--- Reindex terminals starting from a given index
---@param terminals Term[] List of terminal instances
---@param start_index number Starting index for reindexing
function M.reindex_terminals(terminals, start_index)
  for i = start_index, #terminals do
    terminals[i].index = i
  end
end

return M
