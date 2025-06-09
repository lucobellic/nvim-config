return {
  {
    'NeogitOrg/neogit',
    cmd = { 'Neogit' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        '<leader>gn',
        function() require('neogit').open({ kind = 'split' }) end,
        desc = 'Neogit',
      },
      {
        '<leader>gc',
        function() require('neogit').open({ 'commit', kind = 'split' }) end,
        desc = 'Neogit Commit',
      },
    },
    opts = {
      signs = {
        hunk = { '', '' },
        item = { '', '' },
        section = { '', '' },
      },
      graph_style = 'kitty',
      integrations = { snacks = true },
    },
  },
}
