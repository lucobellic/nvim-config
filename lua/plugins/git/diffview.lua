local function refresh_ribbon()
  if vim.g.diff_ribbon then
    require('diff-ribbon').refresh()
  end
end

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
    'dlyongemallo/diffview-plus.nvim',
    cmd = {
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
      'DiffviewRangeFileHistory',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neotest/nvim-nio',
      'diff-ribbon',
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
        '<leader>gdc',
        function()
          local branch = require('util.snacks.picker.git').resolve_origin_base_branch()
          vim.cmd('DiffviewFileHistory --range=' .. branch .. '..HEAD')
        end,
        mode = { 'n' },
        desc = 'Diffview Range origin/base..HEAD',
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
        function()
          local branch = require('util.snacks.picker.git').resolve_origin_base_branch()
          vim.cmd('DiffviewOpen --imply-local ' .. branch .. '...HEAD')
        end,
        mode = { 'n', 'v' },
        desc = 'Diffview origin/base...HEAD',
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
      ---@type DiffviewConfig.user
      local new_opts = {
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
          merge_tool = { layout = 'diff3_mixed' },
          inline = { style = 'unified', deletion_highlight = 'full_width' },
          cycle_layouts = {
            default = { 'diff1_inline', 'diff2_horizontal', 'diff2_vertical' },
            merge_tool = { 'diff1_plain', 'diff3_horizontal', 'diff3_mixed', 'diff3_vertical', 'diff4_mixed' },
          },
        },
        hooks = {
          view_enter = refresh_ribbon,
          view_leave = refresh_ribbon,
          view_closed = refresh_ribbon,
          view_post_layout = refresh_ribbon,
          diff_buf_win_enter = refresh_ribbon,
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
              'g<C-x>',
              require('diffview.actions').cycle_layout,
              { desc = 'Cycle available layouts', repeatable = true },
            },
            {
              'n',
              '<C-s>',
              require('plugins.git.diffview.amend').under_cursor,
              { desc = 'Amend commit with staged file change' },
            },
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
            {
              'n',
              '<C-y>',
              function()
                local view = require('diffview.lib').get_current_view()
                ---@cast view FileHistoryView?
                local file = view and view:infer_cur_file()
                if not (file and file.absolute_path) then
                  vim.notify('No file under cursor', vim.log.levels.WARN)
                  return
                end

                local new_view = require('diffview.lib').file_history(nil, {
                  '--follow',
                  file.absolute_path,
                })
                if new_view then
                  vim.notify('Opening ' .. file.absolute_path .. ' history', vim.log.levels.INFO)
                  new_view:open()
                end
              end,
              { desc = 'Open file history under cursor' },
            },
            {
              'n',
              '<C-m>',
              require('plugins.git.diffview.util').open_containing_merge_history,
              { desc = 'Open containing merge history' },
            },
          },
          view = {
            { 'n', '<leader>b', false },
            {
              'n',
              'g<C-x>',
              require('diffview.actions').cycle_layout,
              { desc = 'Cycle through available layouts', repeatable = true },
            },
            {
              'n',
              '<C-s>',
              require('plugins.git.diffview.amend').under_cursor,
              { desc = 'Amend commit with staged file change' },
            },
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
              'g<C-x>',
              require('diffview.actions').cycle_layout,
              { desc = 'Cycle available layouts', repeatable = true },
            },
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
      }

      return vim.tbl_deep_extend('force', opts, new_opts)
    end,
  },
  {
    dir = vim.fn.stdpath('config') .. '/local/diff-ribbon',
    name = 'diff-ribbon',
    lazy = true,
    enabled = vim.g.diff_ribbon == true,
    dependencies = 'dlyongemallo/diffview-plus.nvim',
    keys = {
      {
        '<leader>uR',
        function()
          local is_enabled = require('diff-ribbon').toggle()
          local text = (is_enabled and 'Enabled' or 'Disabled') .. ' diff ribbon'
          local level = is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
          vim.notify(text, level, { title = 'Options' })
        end,
        desc = 'Toggle Diff Ribbon',
      },
    },
    ---@type DiffRibbon.Options
    opts = {
      width = 4,
      -- Kitty cell size in pixels, used in the container where the terminal cannot report it.
      cell_size = { width = 10, height = 22 },
    },
  },
}
