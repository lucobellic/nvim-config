vim.lsp.enable('cspell_lsp')
vim.lsp.enable('qmlls')
vim.lsp.enable('neocmake')

if vim.fn.has('nvim-0.12') == 1 then
  if vim.g.suggestions == 'copilot' and not vim.env.INSIDE_DOCKER then
    vim.lsp.enable('copilot')
    vim.lsp.inline_completion.enable()
  end
end

-- require('util.separators').setup()

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
