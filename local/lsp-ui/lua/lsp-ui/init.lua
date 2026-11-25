--- Small LSP interface helpers that replace lspsaga.
---
--- Usage:
--- ```lua
--- require('lsp-ui').jump_diagnostic({ count = 1, severity = vim.diagnostic.severity.ERROR })
--- ```
---@class LspUi
local M = {}

local config = require('lsp-ui.config')
local diagnostic = require('lsp-ui.diagnostic')

---@public
---@param opts? LspUi.Config
function M.setup(opts) config.setup(opts) end

--- Jump to a diagnostic and show its message with the available code actions.
--- Enter the float and press the action number to apply it.
---@public
---@param opts vim.diagnostic.JumpOpts
function M.jump_diagnostic(opts) diagnostic.jump(opts) end

return M
