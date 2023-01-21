local cmd = vim.cmd

require 'nvim-treesitter.configs'.setup {
  ensure_installed = {"cmake", "python", "yaml", "json", "vim"},
  highlight = {
    enable = true,
    disable = { "c", "cpp", "rust", "lua" }, -- disable highlight supported by lsp
    custom_captures = {
      -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
      -- ["foo.bar"] = "Constant",
    },
  },
}

if vim.loop.os_uname().sysname:lower():find('windows') then
  require 'nvim-treesitter.install'.compilers = { 'cl', 'clang' }
end
