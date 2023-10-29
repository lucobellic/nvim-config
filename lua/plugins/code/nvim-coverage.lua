return {
  'andythigpen/nvim-coverage',
  event = 'VeryLazy',
  dependencies = 'nvim-lua/plenary.nvim',
  -- Optional: needed for PHP when using the cobertura parser
  -- rocks = { 'lua-xmlreader' },
  config = function()
    require('coverage').setup({
      lang = {
        cpp = {
          coverage_file = './.coverage/lcov.info',
        },
      },
    })
  end,
}
