---@class OpenCodeOptions
---@field split 'right'|'left'|'above'|'below'|string Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to start in insert mode

---@class OpenCodeModule
---@field terminal_buf integer|nil
---@field terminal_win integer|nil
---@field opts OpenCodeOptions
local M = {
  terminal_buf = nil,
  terminal_win = nil,
  opts = {
    split = 'right',
    focus = true,
    insert = true,
  },
}

---Create and open the OpenCode terminal window
---@private
function M.create_opencode_terminal()
  local opts = M.opts or {}
  -- Create a new buffer
  M.terminal_buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_option_value('filetype', 'opencode', { buf = M.terminal_buf })
  M.terminal_win = vim.api.nvim_open_win(M.terminal_buf, opts.focus, { split = opts.split or 'right', win = 0 })

  if opts.focus then
    vim.api.nvim_set_current_buf(M.terminal_buf)
  end

  -- Start terminal with opencode command
  vim.fn.jobstart('opencode', { term = true })

  if opts.insert then
    vim.cmd('startinsert')
  end
end

---Toggle the OpenCode terminal window
function M.toggle_opencode_terminal()
  local opts = M.opts or {}
  -- Check if terminal buffer exists and is valid
  if M.terminal_buf and vim.api.nvim_buf_is_valid(M.terminal_buf) and M.terminal_win then
    if vim.api.nvim_win_is_valid(M.terminal_win) then
      vim.api.nvim_win_hide(M.terminal_win)
    else
      M.terminal_win = vim.api.nvim_open_win(M.terminal_buf, opts.focus, { split = opts.split or 'right', win = 0 })
      if opts.focus then
        vim.api.nvim_set_current_buf(M.terminal_buf)
      end
      if opts.insert then
        vim.cmd('startinsert')
      end
    end
  else
    -- Create new terminal
    M.create_opencode_terminal()
  end
end

---Setup OpenCode integration
---@param opts OpenCodeOptions|nil
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.opts or {}, opts or {})
  vim.api.nvim_create_user_command('OpenCodeToggle', M.toggle_opencode_terminal, {})
end

return M
