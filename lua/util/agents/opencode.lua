---@class OpenCodeOptions
---@field split 'right'|'left'|'above'|'below' Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to enter insert mode in the terminal

---@class OpenCode
---@field opts OpenCodeOptions
local OpenCode = { opts = { split = 'right', focus = true, insert = true } }

---@param opts OpenCodeOptions|nil
function OpenCode.setup(opts)
  OpenCode.opts = vim.tbl_deep_extend('force', OpenCode.opts or {}, opts or {})
  local AgentTerminal = require('util.agents.agent-manager')
  AgentTerminal.new({
    executable = 'opencode',
    filetype = 'opencode',
    display_name = 'OpenCode',
    leader = '<leader>c',
    opts = OpenCode.opts,
  })
end

return OpenCode
