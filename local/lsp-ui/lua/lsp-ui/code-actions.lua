--- Fetch and apply the code actions that fix one diagnostic.
---@class LspUi.CodeActions
local M = {}

---@class LspUi.CodeAction
---@field client_id integer
---@field action lsp.CodeAction|lsp.Command

--- Range in mark format, where the end column is part of the range like a visual selection.
---@param diagnostic vim.Diagnostic
---@return { start: [integer, integer], end: [integer, integer] }
local function diagnostic_range(diagnostic)
  local end_row = diagnostic.end_lnum or diagnostic.lnum
  local end_col = math.max((diagnostic.end_col or diagnostic.col) - 1, 0)
  if end_row == diagnostic.lnum then
    end_col = math.max(end_col, diagnostic.col)
  end
  return {
    start = { diagnostic.lnum + 1, diagnostic.col },
    ['end'] = { end_row + 1, end_col },
  }
end

---@param diagnostic vim.Diagnostic
---@return lsp.CodeActionContext
local function diagnostic_context(diagnostic)
  return {
    diagnostics = vim.lsp.diagnostic.from({ diagnostic }),
    triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
  }
end

---@param results table<integer, { err?: lsp.ResponseError, result?: (lsp.CodeAction|lsp.Command)[] }>
---@return LspUi.CodeAction[]
local function collect(results)
  return vim.iter(pairs(results)):fold({}, function(actions, client_id, response)
    local client_actions = vim.tbl_map(
      function(action) return { client_id = client_id, action = action } end,
      response.result or {}
    )
    return vim.list_extend(actions, client_actions)
  end)
end

--- Ask every attached server for the actions that fix the diagnostic.
---@param bufnr integer
---@param diagnostic vim.Diagnostic
---@param on_result fun(actions: LspUi.CodeAction[])
function M.request(bufnr, diagnostic, on_result)
  if #vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/codeAction' }) == 0 then
    return
  end

  local range = diagnostic_range(diagnostic)
  local context = diagnostic_context(diagnostic)
  vim.lsp.buf_request_all(bufnr, 'textDocument/codeAction', function(client)
    local params = vim.lsp.util.make_given_range_params(range.start, range['end'], bufnr, client.offset_encoding)
    params.context = context
    return params
  end, function(results) on_result(collect(results)) end)
end

--- Go through the built in code action flow so edits, commands and lazy resolved actions all work.
---@param diagnostic vim.Diagnostic
---@param choice LspUi.CodeAction
function M.apply(diagnostic, choice)
  vim.lsp.buf.code_action({
    range = diagnostic_range(diagnostic),
    context = diagnostic_context(diagnostic),
    apply = true,
    filter = function(action, client_id) return client_id == choice.client_id and action.title == choice.action.title end,
  })
end

return M
