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
  AgentTerminal.new({
    executable = 'cursor-agent',
    filetype = 'cursor-agent',
    display_name = 'Cursor Agent',
    leader = '<leader>cc',
    opts = M.opts,
  })

  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>cc', group = 'Cursor Agent', mode = { 'n', 'v' } } }, { notify = false })
  end

end

return M
