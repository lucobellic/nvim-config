local util = require('plugins.lsp.config.util')

-- null-ls
local null_ls = require("null-ls")
local cspell_config = {
  find_json = function(cwd)
    return vim.fn.stdpath("config") .. '/spell/cspell.json'
  end
}

local cspell = require('cspell')
null_ls.setup({
  on_attach = util.on_attach,
  fallback_severity = vim.diagnostic.severity.INFO,
  sources = {
    null_ls.builtins.diagnostics.rstcheck,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.formatting.prettier,
    cspell.diagnostics.with({ config = cspell_config }),
    cspell.code_actions.with({ config = cspell_config }),
  },
})
