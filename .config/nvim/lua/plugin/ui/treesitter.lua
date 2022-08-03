local cmd = vim.cmd

cmd('hi link TSParameter Constant')
cmd('hi link TSParameterReference Constant')
cmd('hi link TSNamespace String')
cmd('hi link TSField Todo')

require'nvim-treesitter.configs'.setup {
  ensure_installed = {"norg", "python"},
  highlight = {
    enable = true,
    disable = {"c", "cpp", "rust", "lua"},
    custom_captures = {
      -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
      -- ["foo.bar"] = "Constant",
    },
  },
}

if vim.loop.os_uname().sysname:lower():find('windows') then
  require 'nvim-treesitter.install'.compilers = {'cl', 'clang'}
end
