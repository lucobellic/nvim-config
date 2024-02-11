-- Disable default keymaps
return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  dependencies = {
    'rafamadriz/friendly-snippets',
    config = function(_, opts)
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({ paths = vim.fn.stdpath('config') .. '/snippets' })
      require('luasnip').filetype_extend('javascript', { 'javascriptreact' })
      require('luasnip').filetype_extend('c', { 'c', 'cdoc' })
      require('luasnip').filetype_extend('cpp', { 'cpp', 'cppdoc' })
    end,
  },
  build = 'make install_jsregexp',
  keys = function() return {} end,
  opts = {},
}
