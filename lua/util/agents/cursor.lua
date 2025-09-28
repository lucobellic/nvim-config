---@class CursorAgentOptions
---@field split 'right'|'left'|'above'|'below'|string Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to enter insert mode in the terminal

---@class CursorAgent
---@field opts CursorAgentOptions
local Cursor = { opts = { split = 'right', focus = true, insert = true } }

---@param opts CursorAgentOptions|nil
function Cursor.setup(opts)
  Cursor.opts = vim.tbl_deep_extend('force', Cursor.opts or {}, opts or {})
  local AgentTerminal = require('util.agents.agent-manager')
  AgentTerminal.new({
    executable = 'cursor-agent',
    filetype = 'cursor-agent',
    display_name = 'Cursor Agent',
    leader = '<leader>lc',
    opts = Cursor.opts,
  })

  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>lc', group = 'Cursor Agent', mode = { 'n', 'v' } } }, { notify = false })
  end
end

return Cursor
