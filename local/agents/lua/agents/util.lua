local M = {}

--- Get all non floating valid windows displaying the given buffer
---@param bufnr integer
---@return integer[] list of window IDs
function M.buf_get_valid_wins(bufnr)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  return vim.tbl_filter(
    function(win)
      return vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_config(win).relative == ''
        and vim.api.nvim_win_get_buf(win) == bufnr
    end,
    wins
  )
end

--- Get normalized visual selection range (handles both top-to-bottom and bottom-to-top)
---@return integer start_line 0-based start line
---@return integer end_line 0-based end line (exclusive)
function M.get_visual_selection_range()
  local start_line = vim.fn.line('v') - 1
  local end_line = vim.fn.line('.') - 1

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return start_line, end_line + 1
end

function M.get_visual_selection_text()
  local start_line, end_line = M.get_visual_selection_range()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
  return table.concat(lines, '\n')
end

--- Setup keymaps and user commands for agent actions
---@param prefix string Keymap prefix (e.g., '<leader>c')
---@param name string Command name prefix (e.g., 'OpenCode')
---@param handlers table Table of handler functions
function M.setup_keymaps_and_commands(prefix, name, handlers)
  local actions = {
    { key = 't', cmd = 'Toggle', handler = handlers.toggle, desc = 'Toggle', mode = 'n' },
    {
      key = 'b',
      cmd = 'SendCurrentBuffer',
      handler = handlers.send_current_buffer,
      desc = 'Send Current Buffer',
      mode = 'n',
    },
    {
      key = 'B',
      cmd = 'SendBuffers',
      handler = handlers.select_and_send_buffers,
      desc = 'Send Buffers',
      mode = 'n',
    },
    {
      key = 't',
      cmd = 'SendTerminals',
      handler = handlers.select_and_send_terminals,
      desc = 'Send Terminals',
      mode = 'n',
    },
    { key = 'f', cmd = 'SendFiles', handler = handlers.select_and_send_files, desc = 'Send Files', mode = 'n' },
    {
      key = 'e',
      cmd = 'SendSelection',
      handler = handlers.send_selection,
      desc = 'Send Selection',
      mode = 'v',
      range = true,
    },
    { key = 'n', cmd = 'New', handler = handlers.create, desc = 'New', mode = 'n' },
    { key = 's', cmd = 'Select', handler = handlers.select, desc = 'Select', mode = 'n' },
  }

  for _, action in ipairs(actions) do
    if action.handler then
      vim.keymap.set(action.mode, prefix .. action.key, action.handler, { desc = name .. ' ' .. action.desc })
      vim.api.nvim_create_user_command(name .. action.cmd, action.handler, { range = action.range or false })
    end
  end

  if handlers.send_buffer_diagnostics then
    vim.keymap.set('n', prefix .. 'd', handlers.send_buffer_diagnostics, { desc = name .. ' Send Buffer Diagnostics' })
    vim.api.nvim_create_user_command(name .. 'SendBufferDiagnostics', handlers.send_buffer_diagnostics, {})
  end

  if handlers.send_selection_diagnostics then
    vim.keymap.set(
      'v',
      prefix .. 'd',
      handlers.send_selection_diagnostics,
      { desc = name .. ' Send Selection Diagnostics' }
    )
    vim.api.nvim_create_user_command(
      name .. 'SendSelectionDiagnostics',
      handlers.send_selection_diagnostics,
      { range = true }
    )
  end

  if handlers.next then
    vim.api.nvim_create_user_command(name .. 'Next', handlers.next, {})
  end
  if handlers.prev then
    vim.api.nvim_create_user_command(name .. 'Prev', handlers.prev, {})
  end
  if handlers.close then
    vim.api.nvim_create_user_command(name .. 'Close', handlers.close, {})
  end
end

return M
