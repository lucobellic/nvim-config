return
{
  'danymat/neogen',
  event = 'VeryLazy',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  opts = {
    snippet_engine = 'luasnip',
    input_after_comment = false,
    languages = {
      python = {
        template = {
          annotation_convention = 'numpydoc',
        }
      }
    }
  }
}
