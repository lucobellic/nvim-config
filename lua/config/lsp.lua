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

-- cpp extra
require('util.cpp').setup()

local ruff_code_severity = {
  ANN001 = vim.diagnostic.severity.INFO,
  ANN201 = vim.diagnostic.severity.INFO,
  ANN202 = vim.diagnostic.severity.INFO,
}

---@param diagnostic lsp.Diagnostic
local function update_diagnostic_severity(diagnostic)
  if diagnostic.source == 'basedpyright' then
    diagnostic.severity = vim.diagnostic.severity.HINT
  elseif ruff_code_severity[diagnostic.code] ~= nil then
    diagnostic.severity = ruff_code_severity[diagnostic.code]
  end
end

---@param error lsp.ResponseError?
---@param result lsp.DocumentDiagnosticReport
---@param ctx lsp.HandlerContext
vim.lsp.handlers['textDocument/diagnostic'] = function(error, result, ctx)
  if result and type(result.items) == 'table' then
    vim.iter(result.items):each(update_diagnostic_severity)
  end
  return vim.lsp.diagnostic.on_diagnostic(error, result, ctx)
end
