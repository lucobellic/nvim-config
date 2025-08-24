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
  AgentTerminal.new({
    executable = 'opencode',
    filetype = 'opencode',
    display_name = 'OpenCode',
    leader = '<leader>c',
    opts = M.opts,
  })
end

return M
