local M = {}

local function save_tab_names()
  local tabs = require('bufferline.tabpages').get()
  vim.g.SCOPETABNAMES = vim
    .iter(tabs)
    :map(function(tab) return tab.component end)
    :map(function(components)
      return vim.iter(components):filter(function(comp) return comp.attr ~= nil end):nth(1)
    end)
    :filter(function(title) return title ~= nil end)
    :totable()
end

local function load_tab_names()
  local tabs = vim.g.SCOPETABNAMES or {}
  vim.iter(tabs):enumerate():each(function(tabnr, tab)
    local name = (tab.text or tostring(tabnr)):match('^%s*(.-)%s*$')
    vim.api.nvim_tabpage_set_var(tabnr, 'name', name)
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
  -- Skip current session loading
  local current = require('persistence').current()
  if vim.bo.filetype ~= 'dashboard' and current == session_file then
    return
  end

  if session_file and vim.fn.filereadable(session_file) ~= 0 then
    -- Save current session before loading a new one
    if vim.bo.filetype ~= 'dashboard' then
      require('persistence').save()
    end

    -- vim.cmd('tabdo Neotree close')
    vim.cmd('silent! %bd!')
    vim.cmd('silent! source ' .. vim.fn.fnameescape(session_file))
  end
end

function M.post_load()
  pcall(load_tab_names)
  vim.cmd('ScopeLoadState')
end

function M.pre_save()
  pcall(save_tab_names)
  vim.cmd('tabmove 0')
  vim.cmd('ScopeSaveState')
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
