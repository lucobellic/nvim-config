return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>gd'] = { name = '+diffview' }
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        '<leader>gdg',
        ':DiffviewOpen<cr>',
        mode = { 'n', 'v' },
        desc = 'Diffview Open',
      },
      {
        '<leader>gdq',
        ':diffoff<cr>',
        mode = { 'n' },
        desc = 'diffoff',
      },
      {
        '<leader>gdF',
        ":0,$DiffviewFileHistory --follow<cr>",
        mode = { 'n' },
        desc = 'Diffview Range File History',
      },
      {
        '<leader>gdf',
        ":DiffviewFileHistory --follow %<cr>",
        mode = { 'n' },
        desc = 'Diffview File History',
      },
      {
        '<leader>gdf',
        ":DiffviewFileHistory<cr>",
        mode = { 'v' },
        desc = 'Diffview File History',
      },
      {
        '<leader>gdd',
        ':DiffviewOpen origin/develop...HEAD<cr>',
        mode = { 'n', 'v' },
        desc = 'Diffview origin/develop...HEAD',
      },
      {
        '<leader>gdw',
        ':windo diffthis<cr>',
        mode = { 'n' },
        desc = 'Windo diffthis',
      },
      {
        '<leader>gdo',
        ':diffthis<cr>',
        mode = { 'n', 'v' },
        desc = 'diffthis',
      },
    },
    opts = {
      diff_binaries = false,   -- Show diffs for binaries
      enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "",
      },
      view = { merge_tool = { layout = 'diff3_mixed' } }
    }
  }
}
