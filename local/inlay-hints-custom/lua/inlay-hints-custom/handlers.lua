--- LSP handlers for inlay hints.
---@class InlayHintsHandlersModule
local M = {}

local log = require('vim.lsp.log')
local state = require('inlay-hints-custom.state')
local util = require('vim.lsp.util')

--- Handler for `textDocument/inlayHint` responses.
---@param err? lsp.ResponseError
---@param result lsp.InlayHint[]?
---@param ctx lsp.HandlerContext
function M.on_inlayhint(err, result, ctx)
  if err then
    log.error('inlayhint', err)
    return
  end
  local bufnr = assert(ctx.bufnr)

  local bufstate = state.get_buf_state(bufnr)
  if util.buf_versions[bufnr] ~= ctx.version or not vim.api.nvim_buf_is_loaded(bufnr) or not bufstate.enabled then
    return
  end

  local client_id = ctx.client_id
  if not (bufstate.client_hints and bufstate.version) then
    bufstate.client_hints = vim.defaulttable()
    bufstate.version = ctx.version
  end

  result = result or {}

  local new_lnum_hints = vim.defaulttable()
  if #result == 0 then
    bufstate.client_hints[client_id] = {}
    bufstate.version = ctx.version
    vim.api.nvim__redraw({ buf = bufnr, valid = true, flush = false })
    return
  end

  local client = assert(vim.lsp.get_client_by_id(client_id))
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for _, hint in ipairs(result) do
    local lnum = hint.position.line
    local line = lines and lines[lnum + 1] or ''
    hint.position.character = vim.str_byteindex(line, client.offset_encoding, hint.position.character, false)
    table.insert(new_lnum_hints[lnum], hint)
  end

  bufstate.client_hints[client_id] = new_lnum_hints
  bufstate.version = ctx.version
  vim.api.nvim__redraw({ buf = bufnr, valid = true, flush = false })
end

--- Handler for `workspace/inlayHint/refresh` server request.
---@param err? lsp.ResponseError
---@param _ any
---@param ctx lsp.HandlerContext
---@return vim.NIL
function M.on_refresh(err, _, ctx)
  if err then
    return vim.NIL
  end
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if not client then
    return vim.NIL
  end

  local refresh = require('inlay-hints-custom.utils').refresh
  for bufnr in pairs(client.attached_buffers or {}) do
    vim
      .iter(vim.api.nvim_list_wins())
      :filter(function(winid) return vim.api.nvim_win_get_buf(winid) == bufnr end)
      :map(function() return state.get_buf_state(bufnr) end)
      :filter(function(bufstate) return bufstate and bufstate.enabled end)
      :each(function(bufstate)
        bufstate.applied = {}
        refresh(bufnr)
      end)
  end
  return vim.NIL
end

return M
