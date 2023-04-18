local normal_bg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg', 'gui')
vim.api.nvim_set_hl(0, "Transparent", { fg = normal_bg, bg = 'none', blend = 0 })

vim.api.nvim_set_hl(0, "OutlineIndent", { fg = "#FF8F40" })
vim.api.nvim_set_hl(0, "SagaShadow"   , { bg = "#000000" })

vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { link = 'NeoTreeDotfile' })
vim.api.nvim_set_hl(0, "NeoTreeGitUnstaged",  { link = 'NeoTreeDotfile' })

