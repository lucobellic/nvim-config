-- Disable default keymaps
return {
  'L3MON4D3/LuaSnip',
  dependencies = { 'rafamadriz/friendly-snippets' },
  keys = function()
    return {}
  end,
  config = function(_, opts)
    require('luasnip').filetype_extend('c', { 'cdoc' })
    require('luasnip').filetype_extend('cpp', { 'cppdoc' })
    require('luasnip.loaders.from_vscode').lazy_load()
  end,
}
