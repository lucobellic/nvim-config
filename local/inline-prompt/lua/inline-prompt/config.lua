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
---@field rain InlinePrompt.RainOptions Digital rain shown over the lines while waiting

---Same meaning as the unimatrix options.
---@class InlinePrompt.RainOptions
---@field speed integer Up to 100, each step below removes 10 milliseconds per frame
---@field flashers boolean Some characters keep changing in place
---@field characters string Character set letter codes among `k`, `n`, `s` and `m`

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
  rain = { speed = 95, flashers = true, characters = 'kns' },
}

---@param opts? InlinePrompt.Options
function M.setup(opts) M.options = vim.tbl_deep_extend('force', M.options, opts or {}) end

return M
