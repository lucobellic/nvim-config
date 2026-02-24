local python_code_severity = {
  I001 = vim.diagnostic.severity.HINT,
  ANN001 = vim.diagnostic.severity.INFO,
  ANN201 = vim.diagnostic.severity.INFO,
  ANN202 = vim.diagnostic.severity.INFO,
  ANN204 = vim.diagnostic.severity.INFO,
}

return {
  handlers = {
    ['textDocument/diagnostic'] = function(error, result, ctx)
      if result and type(result.items) == 'table' then
        vim
          .iter(result.items)
          :filter(function(diagnostic) return python_code_severity[diagnostic.code] ~= nil end)
          :each(function(diagnostic) diagnostic.severity = python_code_severity[diagnostic.code] end)
      end
      return vim.lsp.diagnostic.on_diagnostic(error, result, ctx)
    end,
  },
}
