return {
  'nvimtools/none-ls.nvim',
  dependencies = { 'davidmh/cspell.nvim' },
  event = 'LspAttach',
  opts_extend = { 'sources' },
  opts = function(_, opts)
    local nls = require('null-ls')

    opts = vim.tbl_deep_extend('force', opts or {}, {
      fallback_severity = vim.diagnostic.severity.HINT,
      should_attach = function(buf) return vim.api.nvim_get_option_value('buftype', { buf = buf }) ~= 'prompt' end,
    })

    vim.list_extend(opts.sources or {}, {
      nls.builtins.formatting.prettierd,
      nls.builtins.formatting.mdformat,
      nls.builtins.formatting.nixpkgs_fmt,
      nls.builtins.diagnostics.markdownlint_cli2,
      nls.builtins.diagnostics.rstcheck,
      nls.builtins.code_actions.statix,
      nls.builtins.formatting.gersemi,
    })
    return opts
  end,
}
