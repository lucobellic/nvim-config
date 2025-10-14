vim.lsp.enable('cspell_lsp')
vim.lsp.enable('qmlls')

require('util.separators').setup()

vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    if client.name == 'cspell_lsp' then
      vim.iter(result.diagnostics):each(function(diagnostic) diagnostic.severity = vim.diagnostic.severity.HINT end)
    elseif client.name == 'basedpyright' then
      vim.iter(result.diagnostics):each(function(diagnostic) diagnostic.severity = vim.diagnostic.severity.HINT end)
    end
  end
  return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
end
