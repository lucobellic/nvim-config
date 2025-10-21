--- @type 'astronvim'|'lazyvim'|nil
vim.g.distribution = 'lazyvim'
-- vim.g.distribution = 'astronvim'
-- vim.g.distribution = nil

vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.autoformat = false
vim.g.markdown_folding = true

---@type 'copilot'|'gitlab'|'supermaven'|false
vim.g.suggestions = vim.env.INSIDE_DOCKER and 'gitlab' or 'copilot'
vim.g.winborder = 'single'

local enable_border = true
vim.g.border = {
  enabled = enable_border,
  style = enable_border and vim.g.winborder or { ' ' },
  borderchars = enable_border and { '─', '│', '─', '│', '┌', '┐', '┘', '└' }
    or { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
}

vim.g.ai_cmp = false
vim.g.cmp_mode = 'super-tab' --- @type 'default'|'super-tab'|'enter'|'none'
