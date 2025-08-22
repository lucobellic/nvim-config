---@class AgentTerminalOptions
---@field split 'right'|'left'|'above'|'below'|string
---@field focus boolean
---@field insert boolean

---@class AgentTerminalConfig
---@field executable string Command to launch (e.g., 'opencode')
---@field filetype string Filetype to set on terminal buffer
---@field display_name string Human-readable name (e.g., 'OpenCode')
---@field opts AgentTerminalOptions

---@class AgentTerminal
---@field terminal_buf integer|nil
---@field terminal_win integer|nil
---@field terminal_job_id integer|nil
---@field opts AgentTerminalOptions
---@field _executable string
---@field _filetype string
---@field _display_name string
local AgentTerminal = {}
AgentTerminal.__index = AgentTerminal

--- Create a new terminal controller for a specific external agent/executable.
---@param config AgentTerminalConfig Configuration for the managed terminal
---@return AgentTerminal Managed terminal instance
function AgentTerminal.new(config)
  local self = setmetatable({}, AgentTerminal)
  self.terminal_buf = nil
  self.terminal_win = nil
  self.terminal_job_id = nil
  self._executable = config.executable
  self._filetype = config.filetype
  self._display_name = config.display_name
  self.opts = vim.tbl_deep_extend('force', {
    split = 'right',
    focus = true,
    insert = true,
  }, config.opts or {})
  return self
end

--- Focus the terminal window/buffer and optionally enter insert mode.
function AgentTerminal:focus_terminal()
  local opts = self.opts or {}
  if self.terminal_win and vim.api.nvim_win_is_valid(self.terminal_win) then
    vim.api.nvim_set_current_win(self.terminal_win)
  end
  if opts.focus then
    vim.api.nvim_set_current_buf(self.terminal_buf)
  end
  if opts.insert then
    vim.cmd('startinsert')
  end
end

--- Ensure a terminal exists; optionally focus it if already open.
---@param focus boolean|nil Focus the terminal when it already exists
function AgentTerminal:ensure_terminal(focus)
  if
    not (
      self.terminal_buf
      and vim.api.nvim_buf_is_valid(self.terminal_buf)
      and self.terminal_win
      and vim.api.nvim_win_is_valid(self.terminal_win)
    )
  then
    self:create_terminal()
  elseif focus then
    self:focus_terminal()
  end
end

--- Create the terminal buffer/window and start the agent process.
function AgentTerminal:create_terminal()
  local opts = self.opts or {}
  self.terminal_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('filetype', self._filetype, { buf = self.terminal_buf })
  self.terminal_win = vim.api.nvim_open_win(self.terminal_buf, opts.focus, { split = opts.split or 'right', win = 0 })

  self.terminal_job_id = vim.fn.jobstart(self._executable, {
    term = true,
    on_exit = function()
      -- Close the terminal window when the process exits
      if self.terminal_win and vim.api.nvim_win_is_valid(self.terminal_win) then
        vim.api.nvim_win_close(self.terminal_win, true)
      end
      -- Clean up the terminal buffer and job ID
      self.terminal_job_id = nil
      self.terminal_win = nil
      if self.terminal_buf and vim.api.nvim_buf_is_valid(self.terminal_buf) then
        vim.api.nvim_buf_delete(self.terminal_buf, { force = true })
        self.terminal_buf = nil
      end
    end,
  })

  self:focus_terminal()
end

--- Hide the terminal window if visible; reopen or create it otherwise.
function AgentTerminal:toggle_terminal()
  local opts = self.opts or {}
  if self.terminal_buf and vim.api.nvim_buf_is_valid(self.terminal_buf) and self.terminal_win then
    if vim.api.nvim_win_is_valid(self.terminal_win) then
      vim.api.nvim_win_hide(self.terminal_win)
    else
      self.terminal_win =
        vim.api.nvim_open_win(self.terminal_buf, opts.focus, { split = opts.split or 'right', win = 0 })
      self:focus_terminal()
    end
  else
    self:create_terminal()
  end
end

--- Send one or more file paths to the terminal as @file tokens.
---@param files string[] Absolute or relative file paths
function AgentTerminal:send_files_to_terminal(files)
  self:ensure_terminal(false)
  vim.iter(files):each(function(file) vim.api.nvim_chan_send(self.terminal_job_id, '@' .. file .. ' \x0A') end)
end

--- Prompt, then send the current buffer's file and the user input to the terminal.
function AgentTerminal:send_buffer()
  local file = vim.fn.expand('%:p')
  if file == '' then
    vim.notify('No file to send', vim.log.levels.WARN)
    return
  end

  vim.ui.input({ prompt = 'Ask file:' }, function(input)
    if input ~= nil then
      self:send_files_to_terminal({ file })
      self:send_text_to_terminal(input)
    end
  end)
end

--- Open a file picker and send selected files to the terminal.
function AgentTerminal:select_files()
  local snacks = require('snacks')
  snacks.picker.files({
    title = 'Select Files to Send to ' .. self._display_name,
    confirm = function(picker)
      local files = picker:selected()
      local files_path = vim.iter(files):map(function(f) return f.file end):totable()
      self:send_files_to_terminal(files_path)

      if #files > 0 then
        vim.notify('Sent ' .. #files .. ' file(s) to ' .. self._display_name, vim.log.levels.INFO)
      end

      picker:close()
    end,
  })
end

--- Send arbitrary text to the terminal's job channel.
---@param text string Text to send
function AgentTerminal:send_text_to_terminal(text)
  self:ensure_terminal(false)
  vim.api.nvim_chan_send(self.terminal_job_id, ' ' .. text .. ' ')
end

--- Send the current visual selection as a fenced code block, then prompt for a question.
function AgentTerminal:send_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  local text = table.concat(lines, '\n')

  local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  local formatted_text = '\x0A ' .. '```' .. filetype .. '\x0A' .. text .. '\x0A ' .. '```' .. '\x0A'

  vim.ui.input({ prompt = 'Ask selection:' }, function(input)
    if input ~= nil then
      self:send_files_to_terminal({ vim.fn.expand('%:p') })
      self:send_text_to_terminal(formatted_text)
      self:send_text_to_terminal(input)
    end
  end)

  vim.notify('Sent selection to ' .. self._display_name, vim.log.levels.INFO)
end

return AgentTerminal
