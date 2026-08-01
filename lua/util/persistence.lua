---@class Util.Persistence
local M = {}

---List only the buffers associated with the focused regular tab.
---@param buffers integer[]
---@return nil
local function restore_listed_buffers(buffers)
  local listed = {}
  vim.iter(buffers):each(function(bufnr) listed[bufnr] = true end)
  vim.iter(vim.api.nvim_list_bufs()):each(function(bufnr)
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.bo[bufnr].buflisted = listed[bufnr] == true
    end
  end)
end

---Focus the first regular tab and close every open Diffview.
---@return nil
local function close_diffviews()
  local diffview = package.loaded['diffview']
  local diffview_lib = package.loaded['diffview.lib']
  if not diffview or not diffview_lib then
    return
  end

  local tabpages = vim.api.nvim_list_tabpages()
  local diffview_tabpages = vim
    .iter(tabpages)
    :filter(function(tabpage) return diffview_lib.tabpage_to_view(tabpage) ~= nil end)
    :totable()
  if #diffview_tabpages == 0 then
    return
  end

  local regular_tabpages = vim
    .iter(tabpages)
    :filter(function(tabpage) return diffview_lib.tabpage_to_view(tabpage) == nil end)
    :totable()
  local regular_tabpage = regular_tabpages[1]

  local scope_core = package.loaded['scope.core']
  if regular_tabpage then
    vim.api.nvim_set_current_tabpage(regular_tabpage)
  end

  -- Capture after focusing so Scope has unlisted the Diffview buffers and exposed the regular tab's buffers.
  local scope_cache = {}
  if scope_core and regular_tabpage then
    scope_core.revalidate()
    vim.iter(regular_tabpages):each(function(tabpage) scope_cache[tabpage] = scope_core.cache[tabpage] end)
  end

  local closed_diffview_tabpages = vim
    .iter(diffview_tabpages)
    :filter(function(tabpage) return diffview.close(tabpage, { force = false }) end)
    :totable()

  if scope_core then
    -- Scope removes cache[last_tab] on TabClosed, so restore regular entries and remove only closed Diffviews.
    vim.iter(closed_diffview_tabpages):each(function(tabpage) scope_core.cache[tabpage] = nil end)
    vim.iter(pairs(scope_cache)):each(function(tabpage, buffers) scope_core.cache[tabpage] = buffers end)
    if #closed_diffview_tabpages == #diffview_tabpages and regular_tabpage then
      restore_listed_buffers(scope_cache[regular_tabpage] or {})
    end
  end
end

---Save Scope's cache in tab order instead of hash-table iteration order.
---@return nil
local function save_scope_state()
  vim.cmd('ScopeSaveState')

  local scope_core = require('scope.core')
  local scope_utils = require('scope.utils')
  local cache = vim
    .iter(vim.api.nvim_list_tabpages())
    :map(function(tabpage) return scope_utils.get_buffer_names(scope_core.cache[tabpage] or {}) end)
    :totable()
  vim.g.ScopeState = vim.json.encode({ cache = cache, last_tab = scope_core.last_tab })
end

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
    local name = (tab?.text or tostring(tabnr)):match('^%s*(.-)%s*$')
    local tab = current_tabs[tabnr]
    if tab and name then
      vim.api.nvim_tabpage_set_var(tab, 'name', name)
    end
  end)
end

--- Remap scope_core.cache entries with sequential numeric keys
--- onto the real tabpage handles, preserving order.
--- This ensures scope.core.on_tab_enter, which keys the cache by actual tabpage
--- handles, can locate the correct buffer lists after state deserialization.
local function remap_scope_cache()
  local scope_core = require('scope.core')
  local tabs = vim.api.nvim_list_tabpages()
  local remapped = {}
  vim
    .iter(ipairs(scope_core.cache))
    :map(function(i, buf_ids) return tabs[i], buf_ids end)
    :filter(function(handle) return handle ~= nil end)
    :each(function(handle, buf_ids) remapped[handle] = buf_ids end)
  scope_core.cache = remapped

  -- Re-list current tab's buffers now that the cache is keyed correctly.
  pcall(scope_core.on_tab_enter)
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
  remap_scope_cache()
  load_tab_names()
  require('util.breakpoints').restore_breakpoints()
end

---Close Diffview tabs before switching sessions.
---@public
---@return nil
function M.pre_load() close_diffviews() end

--- Callback before saving session
--- @param session_file string
function M.pre_save(session_file)
  close_diffviews()
  save_scope_state()
  pcall(save_tab_names)
  require('util.breakpoints').save_breakpoints(session_file)
end

---Use Snacks picker to load session from persistence plugin
function M.select_session()
  local sessions = M.get_sorted_sessions()

  -- Build picker items
  local items = vim
    .iter(sessions)
    :map(
      function(session)
        return {
          text = M.get_session_path(session),
          session_file = session,
        }
      end
    )
    :totable()

  Snacks.picker.pick({
    title = 'Load Session',
    layout = { preset = 'telescope_no_preview' },
    items = items,
    format = 'text',
    ---@type snacks.picker.finder
    finder = function(opts, ctx)
      local sessions = M.get_sorted_sessions()
      local items = vim
        .iter(sessions)
        :map(
          function(session)
            return {
              text = M.get_session_path(session),
              session_file = session,
            }
          end
        )
        :totable()
      return ctx.filter:filter(items)
    end,
    actions = {
      confirm = function(picker)
        local item = picker:selected({ fallback = true })[1]
        picker:close()
        if item then
          vim.schedule(function() M.load_session(item.session_file) end)
        end
      end,
      remove = function(picker)
        local selected = picker:selected({ fallback = true })
        vim.iter(selected):each(function(item)
          local session_file = item.session_file
          if vim.fn.filereadable(session_file) == 1 then
            os.remove(session_file)
          end
        end)
        vim.schedule(
          function()
            vim.notify(
              string.format('Removed %d session(s)', #selected),
              vim.log.levels.INFO,
              { title = 'Persistence' }
            )
          end
        )
        picker.list:set_selected()
        picker.list:set_target()
        picker:find()
      end,
    },
    win = {
      input = {
        keys = {
          ['<c-x>'] = { 'remove', mode = { 'i', 'n' } },
        },
      },
    },
  })
end

return M
