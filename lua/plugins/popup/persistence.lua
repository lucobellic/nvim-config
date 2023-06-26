local persistence = require('persistence')
local Path = require('plenary.path')
persistence.setup({
  options = { 'globals', 'buffers', 'curdir', 'folds', 'tabpages', 'winsize' },
  pre_save = function() vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' }) end
})

--- Get persistence sessions sorted by last modification time
local get_sorted_sessions = function()
  local sessions = persistence.list()
  table.sort(sessions, function(a, b)
    return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
  end)
  return sessions
end

--- Get session path from persistence session list
---@param session string session with '%' to be replaced with '/'
local get_session_path = function(session)
  local pos = session:find('%%')
  local session_path = pos and session:sub(pos) or session
  return session_path:gsub('%%', '/'):gsub('.vim$', '')
end


--- Use vim.ui.select() to load session from persistence plugin
local load_session = function()
  local sessions = get_sorted_sessions()

  local display_names = {}
  for _, session in ipairs(sessions) do
    local session_path = get_session_path(session)
    table.insert(display_names, session_path)
  end

  vim.ui.select(display_names, { prompt = 'Load Session' }, function(_, idx)
    if idx then
      local session_file = sessions[idx]
      if session_file and vim.fn.filereadable(session_file) ~= 0 then
        vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
      end
    end
  end)
end

vim.api.nvim_create_user_command('PersistenceLoadSession', load_session, {})
