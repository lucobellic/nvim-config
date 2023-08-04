local cspell_config = {
	find_json = function(cwd)
		return vim.fn.stdpath("config") .. "/spell/cspell.json"
	end,
}

return {
	"jose-elias-alvarez/null-ls.nvim",
	dependencies = {
		"davidmh/cspell.nvim",
	},
	opts = function(_, opts)
    opts.fallback_severity = vim.diagnostic.severity.INFO
		opts.sources = vim.tbl_extend("force", opts.sources, {
			require("null-ls").builtins.diagnostics.rstcheck,
			require("null-ls").builtins.diagnostics.markdownlint,
			require("null-ls").builtins.formatting.prettier,
      -- require("null-ls").builtins.diagnostics.ansiblelint,
			require("cspell").diagnostics.with({ config = cspell_config }),
			require("cspell").code_actions.with({ config = cspell_config }),
		})
	end,
}
