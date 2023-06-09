local util = require('plugins.lsp.config.util')

-- null-ls
local null_ls = require("null-ls")
local cspell = require('cspell')
null_ls.setup({
  on_attach = util.on_attach,
  fallback_severity = vim.diagnostic.severity.INFO,
  sources = {
    null_ls.builtins.diagnostics.rstcheck,
    cspell.diagnostics,
    cspell.code_actions,
  },
})
