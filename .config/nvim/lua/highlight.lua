local cmd = vim.cmd

cmd('hi link TSParameter Constant')
cmd('hi link TSParameterReference Constant')
cmd('hi link TSNamespace String')
cmd('hi link TSField Todo')

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {"c", "cpp", "rust"},
    custom_captures = {
      -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
      -- ["foo.bar"] = "Constant",
    },
  },
}
