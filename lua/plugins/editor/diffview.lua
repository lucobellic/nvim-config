return {
  'sindrets/diffview.nvim',
  event = "VeryLazy",
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>gdg',
      ':DiffviewOpen<cr>',
      mode = { 'n', 'v' },
      desc = 'Diffview Open',
      silent = true
    },
    {
      '<leader>gdq',
      ':DiffviewClose<cr>',
      mode = { 'n', 'v' },
      desc = 'Diffview Close',
      silent = true
    },
    {
      '<leader>gdf',
      ":0,$DiffviewFileHistory --follow<cr>",
      mode = { 'n' },
      desc = 'Diffview File History',
      silent = true
    },
    {
      '<leader>gdd',
      ':DiffviewOpen origin/develop...HEAD<cr>',
      mode = { 'n', 'v' },
      desc =
      'Diffview origin/develop...HEAD',
      silent = true
    },
  },
  otps = {
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
