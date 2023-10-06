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
        ":DiffviewFileHistory --follow<cr>",
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
    opts = function (_, opts)
      opts.diff_binaries = false   -- Show diffs for binaries
      opts.enhanced_diff_hl = true -- See ':h diffview-config-enhanced_diff_hl'
      opts.signs = vim.tbl_extend('force', opts.signs or {}, {
        fold_closed = "",
        fold_open = "",
        done = "",
      })
      opts.view = vim.tbl_extend('force', opts.view or {}, { merge_tool = { layout = 'diff3_mixed' } })

      opts.keymaps = vim.tbl_extend('force', opts.keymaps or {}, {
        file_history_panel = {
          {
            "n",
            "<C-g>",
            require('diffview.actions').open_in_diffview,
            { desc = "Open the entry under the cursor in a diffview" }
          }
        },
      })
    end
  }
}
