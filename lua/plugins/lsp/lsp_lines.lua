return {
  'git@github.com:lucobellic/lsp_lines.nvim.git',
  name = 'lsp_lines',
  branch = 'personal',
  event = 'VeryLazy',
  config = function()
    require('lsp_lines').setup()
  end,
}
