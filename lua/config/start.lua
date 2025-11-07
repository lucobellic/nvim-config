--- @type 'astronvim'|'lazyvim'|nil
vim.g.distribution = 'lazyvim'
-- vim.g.distribution = 'astronvim'
-- vim.g.distribution = nil

vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.autoformat = false
vim.g.markdown_folding = true
vim.g.neovide_floating_shadow = vim.g.neovide

---@type 'copilot'|'gitlab'|'supermaven'|false
vim.g.suggestions = vim.env.INSIDE_DOCKER and 'gitlab' or 'copilot'
vim.g.ai_cmp = false
vim.g.cmp_mode = 'super-tab' --- @type 'default'|'super-tab'|'enter'|'none'
