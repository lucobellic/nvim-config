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
    branch = 'personal',
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
      opts = vim.tbl_deep_extend('force', opts, {
        diff_binaries = false, -- Show diffs for binaries
        icons = { -- Only applies when use_icons is true.
          folder_closed = '',
          folder_open = '',
        },
        signs = {
          fold_closed = '',
          fold_open = '',
          done = '',
        },
        view = {
          merge_tool = {
            layout = 'diff3_mixed',
          },
        },
        keymaps = {
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
        },
      })
      return opts
    end,
  },
}
