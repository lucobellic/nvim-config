return {
  'kevinhwang91/nvim-ufo',
  event = 'VeryLazy',
  dependencies = {
    'kevinhwang91/promise-async',
    {
      'luukvbaal/statuscol.nvim',
      enabled = false,
      opts = {
        ft_ignore = {
          'Outline',
          'sagaoutline',
        }
      },
      config = function()
        local builtin = require('statuscol.builtin')
        require('statuscol').setup({
          relculright = true,
          segments = {
            { text = { builtin.lnumfunc },      click = 'v:lua.ScLa' },
            { text = { '%s' },                  click = 'v:lua.ScSa' },
            { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
          },
        })
      end,
    },
  },
  keys = {
    { 'zR', function() require('ufo').openAllFolds() end },
    { 'zM', function() require('ufo').closeAllFolds() end },
  },
  opts = {},
}
