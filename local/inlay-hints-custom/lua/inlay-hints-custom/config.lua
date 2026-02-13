--- Configuration and type definitions for inlay-hints-custom.
---@class InlayHintsConfigModule
local M = {}

--- LSP inlay hint kind constants (from LSP spec).
---@enum lsp.InlayHintKind
M.kind = {
  Type = 1,
  Parameter = 2,
}

--- The hint object passed to `format_hint`.
--- Contains all information from the LSP InlayHint after label resolution.
--- Most fields come directly from lsp.InlayHint, with label resolved to a string.
---@class InlayHintItem
---@field label string Resolved label text (concatenated from parts if needed)
---@field label_parts? lsp.InlayHintLabelPart[] Original label parts (nil when label was a string)
---@field kind? lsp.InlayHintKind 1 = Type, 2 = Parameter, nil = unknown/offspec
---@field position lsp.Position Hint position in the buffer (already converted to byte offset)
---@field paddingLeft? boolean Whether the hint has padding on the left
---@field paddingRight? boolean Whether the hint has padding on the right
---@field tooltip? string|lsp.MarkupContent Tooltip for the whole hint
---@field textEdits? lsp.TextEdit[] Optional text edits to apply
---@field data? any Server-specific data

--- Result returned from `format_hint` controlling how a single hint is rendered.
--- Return `nil` from `format_hint` to hide the hint entirely.
---@class InlayHintDisplayItem
---@field label string Text to display
---@field highlight? string Highlight group (default: config.highlight)
---@field virt_text_pos? 'inline'|'eol'|'right_align'|'eol_right_align' Override position for this hint (default: config.virt_text_pos)
---@field col? integer Byte column for inline positioning; only used when virt_text_pos='inline'

---@class InlayHintsCustomConfig
---@field enabled? boolean Enable inlay hints on startup (default: true)
---@field virt_text_pos? 'inline'|'eol'|'right_align'|'eol_right_align' Virtual text position (default: 'inline')
---@field highlight? string Highlight group for hints (default: 'LspInlayHint')
---@field hl_mode? 'combine'|'replace' How to blend highlights (default: 'combine')
---@field priority? integer Extmark priority (default: 200)
---@field separator? string Icon/text to display between multiple hints at same position (default: ' ')
---@field format_hint? fun(hint: InlayHintItem, bufnr: integer, client_id: integer): InlayHintDisplayItem? Called per hint; return nil to hide

---@type InlayHintsCustomConfig
M.defaults = {
  enabled = true,
  virt_text_pos = 'inline',
  highlight = 'LspInlayHint',
  hl_mode = 'combine',
  priority = 200,
  separator = ' ',
  format_hint = nil,
}

return M
