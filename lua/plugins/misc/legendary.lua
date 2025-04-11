return {
  'mrjones2014/legendary.nvim',
  enabled = false,
  -- since legendary.nvim handles all your keymaps/commands,
  -- its recommended to load legendary.nvim before other plugins
  priority = 10000,
  lazy = false,
  -- sqlite is only needed if you want to use frecency sorting
  -- dependencies = { 'kkharji/sqlite.lua' }
  keys = { { '<leader>fk', '<cmd>Legendary<cr>', desc = 'Legendary' } },
  cmd = { 'Legendary' },
  opts = {
    extensions = {
      lazy_nvim = true,
      which_key = {
        auto_register = true,
        do_binding = true,
        use_groups = true,
      },
      auto_register = false,
      smart_splits = {
        directions = { 'h', 'j', 'k', 'l' },
        mods = {
          move = '<C>',
        },
      },
      diffview = true,
    },
  },
}
