---@class CursorAgentOptions
---@field split 'right'|'left'|'above'|'below'|string Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to enter insert mode in the terminal

---@class CursorAgentModule
---@field terminal_buf integer|nil Buffer handle for the CursorAgent terminal
---@field terminal_win integer|nil Window handle for the CursorAgent terminal
---@field terminal_job_id integer|nil Job ID for the CursorAgent terminal process
---@field opts CursorAgentOptions Configuration options for CursorAgent integration
local M = {
  terminal_buf = nil,
  terminal_win = nil,
  terminal_job_id = nil,
  opts = {
    split = 'right',
    focus = true,
    insert = true,
  },
}

---Focus the terminal window and optionally enter insert mode
---Switches to the terminal window if it's valid and focuses the buffer if configured.
---@private
function M.focus_terminal()
  local opts = M.opts or {}
  if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
    vim.api.nvim_set_current_win(M.terminal_win)
  end
  if opts.focus then
    vim.api.nvim_set_current_buf(M.terminal_buf)
  end
  if opts.insert then
    vim.cmd('startinsert')
  end
end

---@param focus boolean Whether to focus the terminal after ensuring it exists
---@private
function M.ensure_terminal(focus)
  if
    not (
      M.terminal_buf
      and vim.api.nvim_buf_is_valid(M.terminal_buf)
      and M.terminal_win
      and vim.api.nvim_win_is_valid(M.terminal_win)
    )
  then
    M.create_cursor_agent_terminal()
  elseif focus then
    M.focus_terminal()
  end
end

---Create and open a new CursorAgent terminal window
---Creates a new buffer, sets up the terminal window with configured options,
---starts the CursorAgent process, and focuses the terminal.
function M.create_cursor_agent_terminal()
  local opts = M.opts or {}
  -- Create a new buffer
  M.terminal_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('filetype', 'cursor-agent', { buf = M.terminal_buf })
  M.terminal_win = vim.api.nvim_open_win(M.terminal_buf, opts.focus, { split = opts.split or 'right', win = 0 })

  -- Start terminal with cursor-agent command
  M.terminal_job_id = vim.fn.jobstart('cursor-agent', { term = true })

  M.focus_terminal()
end

---Toggle the visibility of the CursorAgent terminal window
---If the terminal window is visible, hides it. If hidden but buffer exists, shows it.
---If no terminal exists, creates a new one.
function M.toggle_cursor_agent_terminal()
  local opts = M.opts or {}
  -- Check if terminal buffer exists and is valid
  if M.terminal_buf and vim.api.nvim_buf_is_valid(M.terminal_buf) and M.terminal_win then
    if vim.api.nvim_win_is_valid(M.terminal_win) then
      vim.api.nvim_win_hide(M.terminal_win)
    else
      M.terminal_win = vim.api.nvim_open_win(M.terminal_buf, opts.focus, { split = opts.split or 'right', win = 0 })
      M.focus_terminal()
    end
  else
    M.create_cursor_agent_terminal()
  end
end

---Send one or more files to the CursorAgent terminal
---Ensures the terminal is available and sends each file path prefixed with '@' to the terminal.
---@param files string[] Array of file paths to send to CursorAgent
function M.send_files_to_terminal(files)
  M.ensure_terminal(false)
  vim.iter(files):each(function(file) vim.api.nvim_chan_send(M.terminal_job_id, '@' .. file .. ' \n') end)
end

---Send the current buffer file to CursorAgent
---Gets the full path of the current buffer and sends it to the terminal.
---Shows a warning if no file is associated with the buffer.
function M.send_buffer()
  local file = vim.fn.expand('%:p')
  if file == '' then
    vim.notify('No file to send', vim.log.levels.WARN)
    return
  end
  M.send_files_to_terminal({ file })
end

---Open file picker to select and send multiple files to CursorAgent
---Uses Snacks file picker to allow user selection of multiple files,
---then sends all selected files to the CursorAgent terminal.
function M.select_files()
  local snacks = require('snacks')
  snacks.picker.files({
    title = 'Select Files to Send to Cursor Agent',
    confirm = function(picker)
      local files = picker:selected()
      local files_path = vim.iter(files):map(function(file) return file.file end):totable()
      M.send_files_to_terminal(files_path)

      if #files > 0 then
        vim.notify('Sent ' .. #files .. ' file(s) to Cursor Agent', vim.log.levels.INFO)
      end

      picker:close()
    end,
  })
end

---Send arbitrary text to the cursor agent terminal
---Ensures the terminal is available and sends the provided text directly to the terminal.
---@param text string The text content to send to cursor agent
function M.send_text_to_terminal(text)
  M.ensure_terminal(false)
  vim.api.nvim_chan_send(M.terminal_job_id, ' ' .. text .. ' ')
end

---Send the current visual selection to CursorAgent
---Captures the current visual selection, concatenates multi-line selections,
---wraps it with triple backticks and filetype, and sends it to the CursorAgent terminal.
function M.send_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])
  local text = table.concat(lines, '\n')

  local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  local formatted_text = 'From file '
    .. vim.fn.expand('%:p')
    .. ':\n '
    .. '```'
    .. filetype
    .. '\n'
    .. text
    .. '\n '
    .. '```'
    .. '\n'

  M.send_text_to_terminal(formatted_text)

  vim.notify('Sent selection to Cursor Agent', vim.log.levels.INFO)
end

---Setup CursorAgent integration with Neovim
---Configures the module with provided options, creates user commands,
---and sets up default keymaps for CursorAgent functionality.
---@param opts CursorAgentOptions|nil Configuration options (merged with defaults)
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.opts or {}, opts or {})
  vim.api.nvim_create_user_command('CursorAgentToggle', M.toggle_cursor_agent_terminal, {})
  vim.api.nvim_create_user_command('CursorAgentSendBuffer', M.send_buffer, {})
  vim.api.nvim_create_user_command('CursorAgentSendFiles', M.select_files, {})
  vim.api.nvim_create_user_command('CursorAgentSendSelection', M.send_selection, { range = true })

  -- which-key group (if available)
  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>cc', group = 'Cursor Agent', mode = { 'n', 'v' } } }, { notify = false })
  end

  -- Keymaps (under <leader>ca group)
  vim.keymap.set('n', '<leader>cct', M.toggle_cursor_agent_terminal, { desc = 'Cursor Agent Toggle' })
  vim.keymap.set('n', '<leader>ccb', M.send_buffer, { desc = 'Cursor Agent Send Buffer' })
  vim.keymap.set('n', '<leader>ccF', M.select_files, { desc = 'Cursor Agent Send Files' })
  vim.keymap.set('v', '<leader>cce', M.send_selection, { desc = 'Cursor Agent Send Selection' })
end

return M
