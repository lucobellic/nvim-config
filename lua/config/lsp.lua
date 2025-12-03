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

---@type table<string, fun(result: lsp.PublishDiagnosticsParams)>
local diagnostics = {
  ['basedpyright'] = function(result)
    vim.iter(result.diagnostics):each(function(diagnostic) diagnostic.severity = vim.diagnostic.severity.HINT end)
  end,
}

vim.lsp.handlers['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and diagnostics[client.name] then
    diagnostics[client.name](result)
  end
  return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
end
