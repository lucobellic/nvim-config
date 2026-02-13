--- Utility functions for inlay hints.
---@class InlayHintsUtilsModule
local M = {}

local state = require('inlay-hints-custom.state')
local util = require('vim.lsp.util')

--- Resolve the label of an LSP InlayHint to a plain string.
---@param label string|lsp.InlayHintLabelPart[]
---@return string text
---@return lsp.InlayHintLabelPart[]? parts Original parts when label was an array
function M.resolve_label(label)
  if type(label) == 'string' then
    return label, nil
  end
  local parts = {}
  local text = ''
  for _, part in ipairs(label) do
    text = text .. part.value
    parts[#parts + 1] = part
  end
  return text, parts
end

--- Build an InlayHintItem from a raw LSP InlayHint.
---@param hint lsp.InlayHint
---@return InlayHintItem
function M.to_hint_item(hint)
  local text, parts = M.resolve_label(hint.label)
  return {
    label = text,
    label_parts = parts,
    kind = hint.kind,
    position = hint.position,
    paddingLeft = hint.paddingLeft,
    paddingRight = hint.paddingRight,
    tooltip = hint.tooltip,
    textEdits = hint.textEdits,
    data = hint.data,
  }
end

--- Refresh inlay hints for a buffer.
---@param bufnr integer
---@param client_id? integer
function M.refresh(bufnr, client_id)
  for _, client in
    ipairs(vim.lsp.get_clients({
      bufnr = bufnr,
      id = client_id,
      method = 'textDocument/inlayHint',
    }))
  do
    client:request('textDocument/inlayHint', {
      textDocument = util.make_text_document_params(bufnr),
      range = util._make_line_range_params(bufnr, 0, vim.api.nvim_buf_line_count(bufnr) - 1, client.offset_encoding),
    }, nil, bufnr)
  end
end

--- Clear hints for a buffer.
---@param bufnr integer
function M.clear(bufnr)
  bufnr = vim._resolve_bufnr(bufnr)
  local bufstate = state.get_buf_state(bufnr)
  for id in pairs((bufstate or {}).client_hints or {}) do
    bufstate.client_hints[id] = {}
  end
  vim.api.nvim_buf_clear_namespace(bufnr, state.namespace, 0, -1)
  vim.api.nvim__redraw({ buf = bufnr, valid = true, flush = false })
end

--- Disable hints for a buffer.
---@param bufnr integer
function M.disable(bufnr)
  bufnr = vim._resolve_bufnr(bufnr)
  M.clear(bufnr)
  state.clear_buf_state(bufnr)
end

--- Enable hints for a buffer.
---@param bufnr integer
function M.enable(bufnr)
  bufnr = vim._resolve_bufnr(bufnr)
  state.reset_buf_state(bufnr)
  M.refresh(bufnr)
end

return M
