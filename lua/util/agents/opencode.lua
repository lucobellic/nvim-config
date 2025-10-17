---@class OpenCodeOptions
---@field split 'right'|'left'|'above'|'below' Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to enter insert mode in the terminal
---@field manager util.agents.agent-manager.AgentManager|nil The agent manager instance

---@class OpenCode
---@field opts OpenCodeOptions
local OpenCode = { opts = { split = 'right', focus = true, insert = true }, manager = nil }

---@param opts OpenCodeOptions|nil
function OpenCode.setup(opts)
  OpenCode.opts = vim.tbl_deep_extend('force', OpenCode.opts or {}, opts or {})
  local AgentManager = require('util.agents.agent-manager')
  OpenCode.manager = AgentManager.new({
    executable = 'opencode',
    filetype = 'opencode',
    display_name = 'OpenCode',
    leader = '<leader>lo',
    opts = OpenCode.opts,
  })

  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>lo', group = 'OpenCode', mode = { 'n', 'v' } } }, { notify = false })
  end
end

return OpenCode
