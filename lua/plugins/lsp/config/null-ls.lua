return function(_, opts)
  local cspell_config = {
    find_json = function(cwd)
      return vim.fn.stdpath("config") .. '/spell/cspell.json'
    end
  }

  opts.fallback_severity = vim.diagnostic.severity.INFO
  opts.sources = vim.tbl_extend('force', opts.sources, {
    require('null-ls').builtins.diagnostics.rstcheck,
    require('null-ls').builtins.diagnostics.markdownlint,
    require('null-ls').builtins.formatting.prettier,
    require('cspell').diagnostics.with({ config = cspell_config }),
    require('cspell').code_actions.with({ config = cspell_config }),
  })
end
