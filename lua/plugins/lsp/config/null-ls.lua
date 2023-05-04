local util = require('plugins.lsp.config.util')

-- null-ls
local null_ls = require("null-ls")
null_ls.setup({
  on_attach = util.on_attach,
  fallback_severity = vim.diagnostic.severity.INFO,
  sources = {
    -- null_ls.builtins.completion.spell, <- Do not use, bad spell completion
    null_ls.builtins.diagnostics.write_good.with({ filetypes = {} }),
    null_ls.builtins.diagnostics.rstcheck,
  },
})
