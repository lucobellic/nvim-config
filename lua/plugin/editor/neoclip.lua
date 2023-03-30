require('neoclip').setup({
  on_select = {
    move_to_front = false,
  },
  on_paste = {
    set_reg = true,
  },
  keys = {
    telescope = {
      i = {
        select = '<c-,>',
        paste = '<cr>',
      },
      n = {
        select = '<c-,>',
        paste = '<cr>',
      },
    },
  }
})
require('telescope').load_extension('neoclip')
