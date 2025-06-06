return {
  'AckslD/nvim-neoclip.lua',
  optional = true,
  dependencies = { 'kkharji/sqlite.lua' },
  keys = { { '<leader>sy', '<cmd>Telescope neoclip<cr>', desc = 'Find yanks (neoclip)' } },
  opts = {
    enable_persistent_history = true,
    keys = {
      telescope = {
        i = {
          paste = '<cr>',
        },
      },
    },
  },
}
