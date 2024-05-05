vim.fn.matchadd('TelescopeParent', '\t\t.*$')
vim.api.nvim_set_hl(0, 'TelescopeParent', { link = 'Comment' })
