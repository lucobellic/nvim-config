local Term = require('term.term')
local config = require('term.config')
local util = require('term.util')

local M = {
  safe_call = util.safe_call,
  safe_api = util.safe_api,
  safe_delete_buffer = util.safe_delete_buffer,
  clamp = util.clamp,
}

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
  local width = config.get_default_width()
  local height = config.get_default_height()

  if term_opts then
    if type(term_opts.width) == 'number' then
      width = term_opts.width
    end
    if type(term_opts.height) == 'number' then
      height = term_opts.height
    end
  end

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

  local ok = M.safe_api('term: failed to set window buffer', vim.api.nvim_win_set_buf, winid, bufnr)
  if not ok then
    return false
  end

  local win_opts = {
    sidescrolloff = 0,
    signcolumn = 'no',
    wrap = true,
    list = false,
  }
  for opt, value in pairs(win_opts) do
    M.safe_api('term: failed to set window option ' .. opt, vim.api.nvim_set_option_value, opt, value, { win = winid })
  end

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
      local ok, err = pcall(user_on_exit, term, code)
      if not ok then
        vim.notify('term: user on_exit failed: ' .. tostring(err), vim.log.levels.ERROR)
      end
    end
    -- Remove terminal on normal exit to allow fresh creation next time
    if code == 0 then
      vim.schedule(function()
        local ok, err = pcall(remove_fn, name)
        if not ok then
          vim.notify('term: remove failed in on_exit: ' .. tostring(err), vim.log.levels.ERROR)
        end
      end)
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
  if not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify('term: buffer ' .. bufnr .. ' is not valid', vim.log.levels.ERROR)
    return nil
  end

  local ok, buftype =
    M.safe_api('term: failed to get buffer type', vim.api.nvim_get_option_value, 'buftype', { buf = bufnr })
  if not ok then
    return nil
  end

  if buftype ~= 'terminal' then
    vim.notify('term: buffer ' .. bufnr .. ' is not a terminal buffer', vim.log.levels.ERROR)
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
      local ok, err = pcall(self.opts.on_close, self)
      if not ok then
        vim.notify('term: on_close failed: ' .. tostring(err), vim.log.levels.ERROR)
      end
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
