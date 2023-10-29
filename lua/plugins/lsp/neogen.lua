return {
  'danymat/neogen',
  event = 'VeryLazy',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  keys = {
    {
      '<leader>nf',
      function()
        require('neogen').generate({})
      end,
      desc = 'Document',
    },
    {
      '<leader>nc',
      function()
        require('neogen').generate({ type = 'class' })
      end,
      desc = 'Document class',
    },
  },
  opts = {
    snippet_engine = 'luasnip',
    input_after_comment = false,
    languages = {
      python = {
        template = {
          annotation_convention = 'numpydoc',
        },
      },
    },
  },
}
