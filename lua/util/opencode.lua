---@class OpenCodeOptions
---@field split 'right'|'left'|'above'|'below'|string Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to enter insert mode in the terminal

---@class OpenCodeModule
---@field opts OpenCodeOptions
local M = { opts = { split = 'right', focus = true, insert = true } }

---@param opts OpenCodeOptions|nil
function M.setup(opts)
  M.opts = vim.tbl_deep_extend('force', M.opts or {}, opts or {})
  local AgentTerminal = require('util.agent-terminal')
  local agent = AgentTerminal.new({
    executable = 'opencode',
    filetype = 'opencode',
    display_name = 'OpenCode',
    opts = M.opts,
  })

  vim.api.nvim_create_user_command('OpenCodeToggle', function() agent:toggle_terminal() end, {})
  vim.api.nvim_create_user_command('OpenCodeSendBuffer', function() agent:send_buffer() end, {})
  vim.api.nvim_create_user_command('OpenCodeSendFiles', function() agent:select_files() end, {})
  vim.api.nvim_create_user_command('OpenCodeSendSelection', function() agent:send_selection() end, { range = true })

  vim.keymap.set('n', '<leader>ct', function() agent:toggle_terminal() end, { desc = 'OpenCode Toggle' })
  vim.keymap.set('n', '<leader>cb', function() agent:send_buffer() end, { desc = 'OpenCode Send Buffer' })
  vim.keymap.set('n', '<leader>cF', function() agent:select_files() end, { desc = 'OpenCode Send Files' })
  vim.keymap.set('v', '<leader>ce', function() agent:send_selection() end, { desc = 'OpenCode Send Selection' })
end

return M
