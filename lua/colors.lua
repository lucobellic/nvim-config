local normal_bg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg', 'gui')
vim.api.nvim_set_hl(0, "Transparent", { fg = normal_bg, bg = 'none', blend = 0 })

vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatch"     , { bg = "NONE", fg = "#569CD6" })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { bg = "NONE", fg = "#569CD6" })
vim.api.nvim_set_hl(0, "CmpItemKindVariable"  , { bg = "NONE", fg = "#9CDCFE" })
vim.api.nvim_set_hl(0, "CmpItemKindInterface" , { bg = "NONE", fg = "#9CDCFE" })
vim.api.nvim_set_hl(0, "CmpItemKindText"      , { bg = "NONE", fg = "#9CDCFE" })
vim.api.nvim_set_hl(0, "CmpItemKindFunction"  , { bg = "NONE", fg = "#C586C0" })
vim.api.nvim_set_hl(0, "CmpItemKindMethod"    , { bg = "NONE", fg = "#C586C0" })
vim.api.nvim_set_hl(0, "CmpItemKindKeyword"   , { bg = "NONE", fg = "#D4D4D4" })
vim.api.nvim_set_hl(0, "CmpItemKindProperty"  , { bg = "NONE", fg = "#D4D4D4" })
vim.api.nvim_set_hl(0, "CmpItemKindUnit"      , { bg = "NONE", fg = "#D4D4D4" })
vim.api.nvim_set_hl(0, "CmpItemKindCopilot"   , { link = "Identifier" })

vim.api.nvim_set_hl(0, "OutlineIndent", { fg = "#FF8F40" })
vim.api.nvim_set_hl(0, "SagaShadow"   , { bg = "#000000" })

vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { link = 'NeoTreeDotfile' })
vim.api.nvim_set_hl(0, "NeoTreeGitUnstaged",  { link = 'NeoTreeDotfile' })

vim.api.nvim_set_hl(0, "IndentBlankLineChar", { fg = "#273747" })

