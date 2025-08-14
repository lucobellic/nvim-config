---@class CursorAgentOptions
---@field split 'right'|'left'|'above'|'below'|string Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to enter insert mode in the terminal

---@class CursorAgentModule
---@field opts CursorAgentOptions
local M = { opts = { split = 'right', focus = true, insert = true } }

---@param opts CursorAgentOptions|nil
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.opts or {}, opts or {})
  local AgentTerminal = require('util.agent-terminal')
  local agent = AgentTerminal.new({
    executable = 'cursor-agent',
    filetype = 'cursor-agent',
    display_name = 'Cursor Agent',
    opts = M.opts,
  })

  vim.api.nvim_create_user_command('CursorAgentToggle', function() agent:toggle_terminal() end, {})
  vim.api.nvim_create_user_command('CursorAgentSendBuffer', function() agent:send_buffer() end, {})
  vim.api.nvim_create_user_command('CursorAgentSendFiles', function() agent:select_files() end, {})
  vim.api.nvim_create_user_command('CursorAgentSendSelection', function() agent:send_selection() end, { range = true })

  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>cc', group = 'Cursor Agent', mode = { 'n', 'v' } } }, { notify = false })
  end

  vim.keymap.set('n', '<leader>cct', function() agent:toggle_terminal() end, { desc = 'Cursor Agent Toggle' })
  vim.keymap.set('n', '<leader>ccb', function() agent:send_buffer() end, { desc = 'Cursor Agent Send Buffer' })
  vim.keymap.set('n', '<leader>ccF', function() agent:select_files() end, { desc = 'Cursor Agent Send Files' })
  vim.keymap.set('v', '<leader>cce', function() agent:send_selection() end, { desc = 'Cursor Agent Send Selection' })
end

return M
