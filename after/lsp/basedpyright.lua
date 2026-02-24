return {
  handlers = {
    ['textDocument/diagnostic'] = function(error, result, ctx)
      if result and type(result.items) == 'table' then
        vim.iter(result.items):each(
          function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity.HINT
          end
        )
      end
      return vim.lsp.diagnostic.on_diagnostic(error, result, ctx)
    end,
  },
}
