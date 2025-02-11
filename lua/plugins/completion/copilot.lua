return {
  'zbirenbaum/copilot.lua',
  enabled = vim.g.copilot,
  opts = {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      keymap = {
        accept = "<C-CR>"
      }
    },
    filetypes = {
      markdown = true,
      gitcommit = true,
      gitrebase = true,
      hgcommit = true,
      svn = true,
    },
  },
}
