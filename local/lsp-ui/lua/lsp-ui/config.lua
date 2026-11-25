--- Configuration and type definitions for lsp-ui.
---@class LspUi.ConfigModule
local M = {}

---@class LspUi.DiagnosticConfig
---@field float? vim.diagnostic.Opts.Float Options passed to `vim.diagnostic.open_float`
---@field max_actions? integer Number of actions shown, each picked with its digit key

---@class LspUi.Highlights
---@field index? string Highlight for the action number
---@field action? string Highlight for the action title

---@class LspUi.Config
---@field diagnostic? LspUi.DiagnosticConfig
---@field highlights? LspUi.Highlights

---@type LspUi.Config
M.defaults = {
  diagnostic = {
    float = { scope = 'cursor', focus = false, prefix = '- ' },
    max_actions = 9,
  },
  highlights = {
    index = 'Number',
    action = 'NormalFloat',
  },
}

---@type LspUi.Config
M.options = vim.deepcopy(M.defaults)

---@param opts? LspUi.Config
function M.setup(opts) M.options = vim.tbl_deep_extend('force', M.defaults, opts or {}) end

return M
