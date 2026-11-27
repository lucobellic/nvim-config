---@type 'lazyvim'|nil
vim.g.distribution = 'lazyvim'
-- vim.g.distribution = nil

vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.autoformat = false
vim.g.markdown_folding = true
vim.g.neovide_floating_shadow = vim.g.neovide

vim.g.python3_host_prog = '/usr/bin/python3'

---@type 'copilot'|'cursor-tab'|'cursor-cpp'|'gitlab'|'supermaven'|false
vim.g.suggestions = 'cursor-cpp'
vim.g.ai_cmp = false
vim.g.cmp_mode = 'super-tab' --- @type 'default'|'super-tab'|'enter'|'none'

---@type 'layout'|'layout-with-rail'
vim.g.layout = 'layout'

-- Kitty ribbons between diffview sides, with matching gutter colors in the statuscolumn.
vim.g.diff_ribbon = true
