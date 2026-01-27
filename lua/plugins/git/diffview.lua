return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>gd', group = 'diffview' },
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
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
    },
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
        function()
          local file = vim.fn.resolve(vim.fn.expand('%:p'))
          vim.cmd('DiffviewFileHistory --no-merges --follow ' .. vim.fn.fnameescape(file))
        end,
        mode = { 'n' },
        desc = 'Diffview File History',
      },
      {
        '<leader>gdf',
        ':DiffviewFileHistory --no-merges --follow<cr>',
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
      {
        '<leader>gdh',
        function() require('util.diffview_highlight_toggle').toggle() end,
        mode = { 'n' },
        desc = 'Toggle diffview diff highlights',
        repeatable = true,
      },
    },
    opts = function(_, opts)
      return vim.tbl_deep_extend('force', opts, {
        enhanced_diff_hl = true,
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
        default_args = {
          DiffviewOpen = {
            '--imply-local',
          },
          DiffviewFileHistory = {},
        },
        keymaps = {
          file_history_panel = {
            { 'n', '<leader>b', false },
            {
              'n',
              'gq',
              function()
                require('diffview.actions').toggle_files()
                vim.schedule(function() vim.cmd('tabclose') end)
              end,
            },
            {
              'n',
              '<C-g>',
              require('diffview.actions').open_in_diffview,
              { desc = 'Open the entry under the cursor in a diffview' },
            },
            -- Fixup commit under cursor
            {
              'n',
              '<C-s>',
              function()
                local lazy = require('diffview.lazy')
                ---@type FileHistoryView|LazyModule
                local FileHistoryView =
                  lazy.access('diffview.scene.views.file_history.file_history_view', 'FileHistoryView')
                local view = require('diffview.lib').get_current_view()
                if view and view:instanceof(FileHistoryView.__get()) then
                  ---@cast view DiffView|FileHistoryView
                  local file = view:infer_cur_file()
                  local item = view.panel:get_item_at_cursor()

                  if file and item then
                    local path = file.absolute_path
                    vim.system({ 'git', 'stash', '--keep-index' })
                    vim.system({ 'git', 'commit', '--fixup=' .. item.commit.hash, '--', path })
                    vim.system({ 'git', 'stash', 'pop', '--index' })
                    vim.schedule(function() vim.notify('Fixup ' .. item.commit.hash, vim.log.levels.INFO) end)
                  end
                end
              end,
              { desc = 'Fixup current file staged change' },
            },
          },
          view = {
            { 'n', '<leader>b', false },
            {
              'n',
              'gq',
              function()
                require('diffview.actions').toggle_files()
                vim.schedule(function() vim.cmd('tabclose') end)
              end,
            },
          },
          file_panel = {
            { 'n', '<leader>b', false },
            {
              'n',
              'gq',
              function()
                require('diffview.actions').toggle_files()
                vim.schedule(function() vim.cmd('tabclose') end)
              end,
            },
          },
        },
      })
    end,
  },
}
