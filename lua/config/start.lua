--- @type 'astronvim'|'lazyvim'|nil
vim.g.distribution = 'lazyvim'
-- vim.g.distribution = 'astronvim'
-- vim.g.distribution = nil

vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.autoformat = false
vim.g.markdown_folding = true
vim.g.neovide_floating_shadow = vim.g.neovide

vim.g.python3_host_prog = '/usr/bin/python3'

---@type 'copilot'|'gitlab'|'supermaven'|false
vim.g.suggestions = (not vim.env.INSIDE_DOCKER) and 'copilot' or false
vim.g.ai_cmp = false
vim.g.cmp_mode = 'super-tab' --- @type 'default'|'super-tab'|'enter'|'none'
