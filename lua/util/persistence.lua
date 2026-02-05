local M = {}

local function save_tab_names()
  local tabs = require('bufferline.tabpages').get()
  local tab_names = vim
    .iter(tabs)
    :map(function(tab) return tab.component end)
    :map(function(components)
      return vim.iter(components):filter(function(comp) return comp.attr ~= nil end):next()
    end)
    :filter(function(title) return title ~= nil end)
    :totable()
  vim.g.ScopeTabNames = vim.json.encode(tab_names)
end

local function load_tab_names()
  local tabs = vim.json.decode(vim.g.ScopeTabNames or '{}')
  local current_tabs = vim.api.nvim_list_tabpages()
  vim.iter(tabs):enumerate():each(function(tabnr, tab)
    local name = (tab.text or tostring(tabnr)):match('^%s*(.-)%s*$')
    local tab = current_tabs[tabnr]
    if tab and name then
      vim.api.nvim_tabpage_set_var(tab, 'name', name)
    end
  end)
end

local function load_tab_buffers()
  vim
    .iter(vim.api.nvim_list_bufs())
    :filter(function(bufnr) return vim.api.nvim_buf_is_valid(bufnr) and not vim.api.nvim_buf_is_loaded(bufnr) end)
    :filter(function(bufnr) return vim.api.nvim_buf_get_name(bufnr) ~= '' end)
    :each(function(bufnr)
      vim.fn.bufload(bufnr)
      vim.api.nvim_buf_call(bufnr, function() vim.cmd('filetype detect') end)
    end)
end

---Get persistence sessions sorted by last modification time
---@return string[] sessions
function M.get_sorted_sessions()
  local sessions = require('persistence').list()
  table.sort(sessions, function(a, b) return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec end)
  return sessions
end

---Get session path from persistence session list
---@param session string session with '%' to be replaced with '/'
function M.get_session_path(session)
  local pos = session:find('%%')
  local session_path = pos and session:sub(pos) or session
  return session_path:gsub('%%', '/'):gsub('.vim$', '')
end

---Load session from file
---@param session_file string
function M.load_session(session_file)
  local persistence = require('persistence')
  -- Skip current session loading
  local current = persistence.current()
  if vim.bo.filetype ~= 'dashboard' and current == session_file then
    return
  end

  if session_file and vim.fn.filereadable(session_file) ~= 0 then
    -- Save current session before loading a new one
    if vim.bo.filetype ~= 'dashboard' then
      persistence.fire('SavePre')
      persistence.save()
      persistence.fire('SavePost')
    end

    persistence.fire('LoadPre')
    vim.cmd('silent! source ' .. vim.fn.fnameescape(session_file))
    persistence.fire('LoadPost')
  end
end

--- Callback after loading session
function M.post_load()
  vim.cmd('ScopeLoadState')
  load_tab_names()
  load_tab_buffers()
  require('util.breakpoints').restore_breakpoints()
end

--- Callback before saving session
--- @param session_file string
function M.pre_save(session_file)
  vim.cmd('ScopeSaveState')
  pcall(save_tab_names)
  require('util.breakpoints').save_breakpoints(session_file)
end

---Use vim.ui.select() to load session from persistence plugin
function M.select_session()
  local sessions = M.get_sorted_sessions()

  local display_names = {}
  for _, session in ipairs(sessions) do
    local session_path = M.get_session_path(session)
    table.insert(display_names, session_path)
  end

  vim.ui.select(display_names, { prompt = 'Load Session' }, function(_, idx)
    if idx then
      M.load_session(sessions[idx])
    end
  end)
end

return M
