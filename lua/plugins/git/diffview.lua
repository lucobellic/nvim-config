return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>gd'] = { name = '+diffview' },
      },
    },
  },
  {
    -- use personal branch until https://github.com/sindrets/diffview.nvim/pull/463
    'lucobellic/diffview.nvim',
    cmd = {
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
      'DiffviewRangeFileHistory',
      'DiffviewOriginDevelopHead',
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      {
        '<leader>gdg',
        '<cmd>DiffviewOpen<cr>',
        mode = { 'n', 'v' },
        desc = 'Diffview Open',
      },
      {
        '<leader>gdq',
        '<cmd>diffoff<cr>',
        mode = { 'n' },
        desc = 'diffoff',
      },
      {
        '<leader>gdF',
        '<cmd>0,$DiffviewFileHistory --follow<cr>',
        mode = { 'n' },
        desc = 'Diffview Range File History',
      },
      {
        '<leader>gdf',
        '<cmd>DiffviewFileHistory --follow %<cr>',
        mode = { 'n' },
        desc = 'Diffview File History',
      },
      {
        '<leader>gdf',
        ':DiffviewFileHistory<cr>',
        mode = { 'v' },
        desc = 'Diffview File History',
      },
      {
        '<leader>gdd',
        '<cmd>DiffviewOpen --imply-local origin/develop...HEAD<cr>',
        mode = { 'n', 'v' },
        desc = 'Diffview origin/develop...HEAD',
      },
      {
        '<leader>gdw',
        '<cmd>windo diffthis<cr>',
        mode = { 'n' },
        desc = 'Windo diffthis',
      },
      {
        '<leader>gdo',
        '<cmd>diffthis<cr>',
        mode = { 'n', 'v' },
        desc = 'diffthis',
      },
    },
    opts = function(_, opts)
      opts.diff_binaries = false -- Show diffs for binaries
      opts.enhanced_diff_hl = true -- See '<cmd>h diffview-config-enhanced_diff_hl'
      opts.signs = vim.tbl_extend('force', opts.signs or {}, {
        fold_closed = '',
        fold_open = '',
        done = '',
      })
      opts.view = vim.tbl_extend('force', opts.view or {}, { merge_tool = { layout = 'diff3_mixed' } })

      opts.keymaps = vim.tbl_extend('force', opts.keymaps or {}, {
        view = {
          ['<leader>wh'] = require('diffview.actions').toggle_files,
        },
        file_history_panel = {
          {
            'n',
            '<C-g>',
            require('diffview.actions').open_in_diffview,
            { desc = 'Open the entry under the cursor in a diffview' },
          },
        },
      })
    end,
  },
}
