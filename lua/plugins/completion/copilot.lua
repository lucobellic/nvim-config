return {
  'zbirenbaum/copilot.lua',
  enabled = not vim.g.started_by_firenvim,
  opts = {
    filetypes = {
      markdown = true,
      gitcommit = true,
      gitrebase = true,
      hgcommit = true,
      svn = true,
    },
  },
}
