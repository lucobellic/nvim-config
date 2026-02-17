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
