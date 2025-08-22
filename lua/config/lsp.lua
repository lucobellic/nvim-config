vim.lsp.enable('cspell_lsp')
vim.lsp.enable('qmlls')
vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == 'cspell_lsp' then
    for _, diagnostic in ipairs(result.diagnostics) do
      diagnostic.severity = vim.diagnostic.severity.HINT
    end
    return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
  end
  return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
end
