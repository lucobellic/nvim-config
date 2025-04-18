local cspell_config = {
  find_json = function(cwd) return vim.fn.stdpath('config') .. '/spell/cspell.json' end,
}

return {
  'nvimtools/none-ls.nvim',
  enabled = true,
  dependencies = { 'davidmh/cspell.nvim' },
  opts_extend = { 'sources' },
  opts = function(_, opts)
    local nls = require('null-ls')
    local cspell = require('cspell')

    opts = vim.tbl_deep_extend('force', opts or {}, {
      fallback_severity = vim.diagnostic.severity.HINT,
    })

    vim.list_extend(opts.sources or {}, {
      nls.builtins.formatting.prettierd,
      nls.builtins.formatting.mdformat,
      nls.builtins.formatting.nixpkgs_fmt,
      nls.builtins.diagnostics.markdownlint_cli2,
      nls.builtins.code_actions.statix,
      nls.builtins.formatting.gersemi,
      cspell.diagnostics.with({ filetypes = {}, config = cspell_config }),
      cspell.code_actions.with({ filetypes = {}, config = cspell_config }),
    })
    return opts
  end,
}
