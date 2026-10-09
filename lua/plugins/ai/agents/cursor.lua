---@class CursorAgent.Session: snacks.picker.Item
---@field session_id string
---@field attached boolean

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
        return {
          session_id = session_id,
          attached = vim.startswith(status, 'Attached'),
          text = task .. ' - ' .. status,
          preview = { text = vim.trim(block), ft = 'text' },
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

---@param picker snacks.Picker
local function stop_cursor_sessions(picker)
  vim.iter(picker:selected({ fallback = true })):each(
    ---@param item CursorAgent.Session
    function(item)
      vim.system(
        { 'agent', 'persist', 'stop', item.session_id },
        { text = true, timeout = 10000 },
        ---@param result vim.SystemCompleted
        function(result)
          vim.schedule(function()
            if result.code ~= 0 then
              vim.notify('Failed to stop Cursor session: ' .. vim.trim(result.stderr or ''), vim.log.levels.ERROR)
              return
            end

            if picker.closed then
              return
            end

            picker.preview:reset()
            picker.opts.items = vim
              .iter(picker.opts.items or {})
              :filter(
                ---@param session CursorAgent.Session
                ---@return boolean
                function(session) return session.session_id ~= item.session_id end
              )
              :totable()
            picker:refresh()
          end)
        end
      )
    end
  )
end

---@param picker snacks.Picker
local function detach_cursor_sessions(picker)
  local tmux = vim.env.CURSOR_AGENT_TMUX_PATH
    or (vim.env.AGENT_TMUX_ROOT_PATH and vim.env.AGENT_TMUX_ROOT_PATH .. '/bin/tmux')
    or 'tmux'
  vim.iter(picker:selected({ fallback = true })):each(
    ---@param item CursorAgent.Session
    function(item)
      if not item.attached then
        return
      end

      vim.system(
        {
          tmux,
          '-L',
          vim.env.CURSOR_AGENT_TMUX_SERVER_NAME or 'cursor-agent',
          'detach-client',
          '-s',
          '=' .. item.session_id,
        },
        { text = true, timeout = 10000, env = { TMUX_TMPDIR = '/tmp' } },
        ---@param result vim.SystemCompleted
        function(result)
          if result.code ~= 0 then
            vim.schedule(
              function()
                vim.notify('Failed to detach Cursor session: ' .. vim.trim(result.stderr or ''), vim.log.levels.ERROR)
              end
            )
            return
          end

          vim.system(
            { 'agent', 'persist', 'list' },
            { text = true, timeout = 10000 },
            ---@param sessions vim.SystemCompleted
            function(sessions)
              vim.schedule(function()
                if sessions.code ~= 0 then
                  vim.notify(
                    'Failed to list Cursor sessions: ' .. vim.trim(sessions.stderr or ''),
                    vim.log.levels.ERROR
                  )
                  return
                end
                if not picker.closed then
                  picker.preview:reset()
                  picker.opts.items = parse_cursor_sessions(sessions.stdout or '')
                  picker:refresh()
                end
              end)
            end
          )
        end
      )
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
          preview = 'preview',
          layout = { preset = 'vertical', preview = true },
          confirm = attach_cursor_session,
          actions = { remove = stop_cursor_sessions, detach = detach_cursor_sessions },
          win = {
            input = {
              keys = {
                ['<c-x>'] = { 'remove', mode = { 'i', 'n' } },
                ['<c-d>'] = { 'detach', mode = { 'i', 'n' } },
              },
            },
          },
        })
      end)
    end
  )
end

---@public
M.pick_cursor_session = pick_cursor_session

return M
