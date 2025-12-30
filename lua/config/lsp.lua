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

---@param error lsp.ResponseError?
---@param result lsp.DocumentDiagnosticReport
---@param ctx lsp.HandlerContext
vim.lsp.handlers['textDocument/diagnostic'] = function(error, result, ctx)
  if type(result.items) == 'table' then
    vim
      .iter(result.items)
      :filter(function(diagnostic) return diagnostic.source == 'basedpyright' end)
      :each(function(diagnostic) diagnostic.severity = vim.diagnostic.severity.HINT end)
  end
  return vim.lsp.diagnostic.on_diagnostic(error, result, ctx)
end
