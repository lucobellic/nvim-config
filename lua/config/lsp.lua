vim.lsp.enable('codebook')
vim.lsp.enable('qmlls')
vim.lsp.enable('neocmake')

if vim.fn.has('nvim-0.12') == 1 then
  if vim.g.suggestions == 'copilot' then
    vim.lsp.enable('copilot')
    vim.lsp.inline_completion.enable()
  end
end

require('util.separators').setup({ enabled = false })

---@type table<string, fun(params: lsp.PublishDiagnosticsParams)>
local diagnostics = {
  ['basedpyright'] = function(params)
    vim.iter(params.diagnostics):each(function(diagnostic) diagnostic.severity = vim.diagnostic.severity.HINT end)
  end,
}

---@param response_error? lsp.ResponseError,
---@param params lsp.PublishDiagnosticsParams
---@param context lsp.HandlerContext
vim.lsp.handlers['textDocument/publishDiagnostics'] = function(response_error, params, context, _)
  local client = vim.lsp.get_client_by_id(context.client_id)
  if client and diagnostics[client.name] then
    pcall(diagnostics[client.name], params)
  end
  return vim.lsp.diagnostic.on_publish_diagnostics(response_error, params, context)
end
