---@class CursorAgent.Session: snacks.picker.Item
---@field session_id string

---@class CursorAgent
local M = {}

---@param output string
---@return CursorAgent.Session[]
local function parse_cursor_sessions(output)
  output = output:gsub('\27%[[%d;]*m', '')
  return vim
    .iter(vim.split(output, '\n\n', { trimempty = true }))
    :map(
      ---@param block string
      ---@return CursorAgent.Session?
      function(block)
        local session_id = block:match('Session:%s*([^%s]+)')
        if not session_id then
          return
        end

        local task = block:match('Task:[ \t]*([^\r\n]+)') or session_id
        local status = block:match('Status:[ \t]*([^\r\n]+)') or ''
        local workspace = block:match('Workspace:[ \t]*([^\r\n]+)') or ''
        return {
          session_id = session_id,
          text = table.concat({ task, status, workspace, session_id }, ' | '),
        }
      end
    )
    :totable()
end

---@param picker snacks.Picker
---@param item CursorAgent.Session?
local function attach_cursor_session(picker, item)
  picker:close()
  if not item then
    return
  end

  vim.schedule(
    function()
      Snacks.terminal({ 'agent', 'persist', 'attach', item.session_id }, {
        env = { TERM = 'xterm-256color' },
        start_insert = false,
        auto_insert = false,
        win = { position = 'right', bo = { filetype = 'cursor-agent' } },
      })
    end
  )
end

local function pick_cursor_session()
  if vim.fn.executable('agent') == 0 then
    vim.notify('Cursor agent executable not found', vim.log.levels.ERROR)
    return
  end

  vim.system(
    { 'agent', 'persist', 'list' },
    { text = true, timeout = 10000 },
    ---@param result vim.SystemCompleted
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify('Failed to list Cursor sessions: ' .. vim.trim(result.stderr or ''), vim.log.levels.ERROR)
          return
        end

        local items = parse_cursor_sessions(result.stdout or '')
        if #items == 0 then
          vim.notify('No persistent Cursor sessions available', vim.log.levels.INFO)
          return
        end

        Snacks.picker({
          title = 'Cursor Agent Sessions',
          items = items,
          format = 'text',
          confirm = attach_cursor_session,
        })
      end)
    end
  )
end

---@public
M.pick_cursor_session = pick_cursor_session

return M
