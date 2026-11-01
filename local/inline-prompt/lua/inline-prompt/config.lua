---@class InlinePrompt.Model
---@field provider 'claude'|'codex' Module in `inline-prompt.providers` that runs the model
---@field id string Model name passed to the CLI
---@field effort? string Reasoning effort
---@field thinking? boolean Set to false to turn reasoning off when the CLI supports it

---@class InlinePrompt.Options
---@field model string Name of the model used by default
---@field models table<string, InlinePrompt.Model>
---@field context_lines integer Lines sent before and after the selection
---@field timeout integer Request timeout in milliseconds
---@field shuffle_interval integer Time in milliseconds between two shuffles of the text while waiting

---@class InlinePrompt.Config
---@field options InlinePrompt.Options
local M = {}

---@type InlinePrompt.Options
M.options = {
  model = 'sonnet',
  models = {
    sonnet = { provider = 'claude', id = 'sonnet', effort = 'low' },
    haiku = { provider = 'claude', id = 'haiku', thinking = false },
    luna = { provider = 'codex', id = 'gpt-6-luna', effort = 'low' },
    sol = { provider = 'codex', id = 'gpt-6-sol', effort = 'low' },
  },
  context_lines = 100,
  timeout = 120000,
  shuffle_interval = 80,
}

---@param opts? InlinePrompt.Options
function M.setup(opts) M.options = vim.tbl_deep_extend('force', M.options, opts or {}) end

return M
