vim.api.nvim_set_hl(0, 'Gold', { fg = "gold" })
vim.api.nvim_set_hl(0, 'Orchid', { fg = "orchid" })
vim.api.nvim_set_hl(0, 'LightSkyBlue', { fg = "LightSkyBlue" })
vim.api.nvim_set_hl(0, 'DarkOrange', { fg = "DarkOrange" })

require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "cmake", "python", "yaml", "json", "vim", "markdown" },
  highlight = {
    enable = true,
    disable = { "c", "cpp", "rust", "lua" }, -- disable highlight supported by lsp
    custom_captures = {
      -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
      -- ["foo.bar"] = "Constant",
    },
  },
  rainbow = {
    enable = true,
    hlgroups = {
      'Gold',
      'Orchid',
      'LightSkyBlue',
      'DarkOrange',
      'TSRainbowGreen',
      'TSRainbowViolet',
      'TSRainbowCyan'
    },
  }
}

if vim.loop.os_uname().sysname:lower():find('windows') then
  require 'nvim-treesitter.install'.compilers = { 'cl', 'clang' }
end
