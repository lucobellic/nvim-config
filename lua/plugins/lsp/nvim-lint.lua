return {
  'mfussenegger/nvim-lint',
  opts = function(_, opts)
    -- Configure cspell to using config file
    local cspell_args = require('lint.linters.cspell').args
    local cspell_config_file = vim.fn.stdpath('config') .. '/spell/cspell.json'
    require('lint.linters.cspell').args = vim.tbl_extend('force', cspell_args, {
      '--config',
      cspell_config_file,
    })
    -- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    -- 	pattern = "*",
    -- 	callback = function(ev)
    -- 		require("lint").try_lint({ "cspell" })
    -- 	end,
    -- 	desc = "Perform cspell lint for all files",
    -- })
  end,
}
