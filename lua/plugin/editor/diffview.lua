local actions = require("diffview.actions")

-- colors
vim.cmd("hi! link DiffviewDiffDelete Comment")
vim.cmd("hi! link DiffviewDiffAddAsDelete Comment")

require("diffview").setup({
  diff_binaries = false, -- Show diffs for binaries
  enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
  signs = {
    fold_closed = "",
    fold_open = "",
    done = "",
  },
})
