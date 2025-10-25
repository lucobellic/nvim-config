---@class GeminiAgentOptions
---@field split 'right'|'left'|'above'|'below'|string Split direction for the window
---@field focus boolean Whether to focus the window
---@field insert boolean Whether to enter insert mode in the terminal
---@field manager util.agents.agent-manager.AgentManager|nil The agent manager instance

---@class GeminiAgent
---@field opts GeminiAgentOptions
local Gemini = { opts = { split = 'right', focus = true, insert = true } }

---@param opts GeminiAgentOptions|nil
function Gemini.setup(opts)
  Gemini.opts = vim.tbl_deep_extend('force', Gemini.opts or {}, opts or {})
  local AgentTerminal = require('util.agents.agent-manager')
  Gemini.manager = AgentTerminal.new({
    executable = 'gemini',
    filetype = 'gemini',
    display_name = 'Gemini',
    leader = '<leader>lg',
    opts = Gemini.opts,
  })

  local ok, wk = pcall(require, 'which-key')
  if ok then
    wk.add({ { '<leader>lg', group = 'Gemini', mode = { 'n', 'v' } } }, { notify = false })
  end
end

return Gemini
