local cspell_config = {
  find_json = function(cwd) return vim.fn.stdpath('config') .. '/spell/cspell.json' end,
}

return {
  'nvimtools/none-ls.nvim',
  enabled = true,
  dependencies = { 'davidmh/cspell.nvim' },
  opts = function(_, opts)
    local nls = require('null-ls')
    opts.fallback_severity = vim.diagnostic.severity.INFO
    table.insert(opts.sources, nls.builtins.formatting.prettierd)
    table.insert(opts.sources, nls.builtins.diagnostics.markdownlint_cli2)
    table.insert(opts.sources, nls.builtins.formatting.prettierd)
    table.insert(opts.sources, nls.builtins.formatting.mdformat)
    -- table.insert(opts.sources, nls.builtins.formatting.ruff)
    -- table.insert(opts.sources, nls.builtins.completion.spell)
    -- table.insert(opts.sources, nls.builtins.formatting.codespell)

    local cspell = require('cspell')
    table.insert(opts.sources, cspell.diagnostics.with({ filetypes = {}, config = cspell_config }))
    table.insert(opts.sources, cspell.code_actions.with({ filetypes = {}, config = cspell_config }))
    return opts
  end,
}
