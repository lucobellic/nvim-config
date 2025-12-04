return {
  'MunifTanjim/nui.nvim',
  lazy = true,
  keys = {
    -- Global keymaps
    { '<F7>', function() require('util.term.core').toggle() end, desc = 'Toggle Terminal' },
    {
      '<S-F7>',
      function()
        local core = require('util.term.core')
        if core.popup then
          core.popup:unmount()
        end
      end,
      desc = 'Term Unmount',
    },

    -- Named terminal keymaps
    { '<leader>er', function() require('util.term.core').toggle('ranger') end, desc = 'Ranger File Manager' },
    { '<leader>g;', function() require('util.term.core').toggle('lazygit') end, desc = 'LazyGit' },
    { '<leader>eg', function() require('util.term.core').toggle('lazygit') end, desc = 'LazyGit' },
    { '<leader>ey', function() require('util.term.core').toggle('yazi') end, desc = 'Yazi File Manager' },
    { '<leader>ed', function() require('util.term.core').toggle('lazydash') end, desc = 'LazyDash' },

    -- Terminal picker (Snacks integration)
    {
      '<leader>sf',
      function()
        if not Snacks or not Snacks.picker then
          return
        end
        local terminals = require('util.term.core').list()
        local items = vim.tbl_map(
          function(term)
            return {
              text = string.format('%d: %s [%s]', term.index, term.title, term.name),
              term = term,
            }
          end,
          terminals
        )

        Snacks.picker.pick({
          title = 'Terminals',
          items = items,
          format = 'text',
          actions = {
            confirm = function(picker, item)
              require('util.term.core').open(item.term.name)
              picker:close()
            end,
          },
        })
      end,
      desc = 'Find Terminals',
    },
  },
  config = function()
    local config = require('util.term.config')
    local core = require('util.term.core')

    -- Setup with configuration
    config.setup({
      defaults = {
        width = 0.6,
        height = 0.6,
        border = 'auto',
        zindex = 50,
      },
      terminals = {
        lazygit = {
          cmd = 'lazygit',
          opts = {
            title = 'LazyGit',
            on_exit = function() vim.cmd('checktime') end,
            width = 0.8,
            height = 0.8,
            start_insert = true,
          },
        },
        yazi = {
          cmd = 'yazi',
          opts = {
            title = 'Yazi',
            width = 0.8,
            height = 0.8,
            start_insert = true,
          },
        },
        lazydash = {
          cmd = 'lazydocker',
          opts = {
            title = 'LazyDash',
            width = 0.8,
            height = 0.8,
            start_insert = true,
          },
        },
      },
    })

    -- User commands
    vim.api.nvim_create_user_command('TermToggle', function(args)
      local name = args.args ~= '' and args.args or nil
      core.toggle(name)
    end, { nargs = '?', desc = 'Toggle terminal' })

    vim.api.nvim_create_user_command('ToggleTerminal', function(args)
      local name = args.args ~= '' and args.args or nil
      core.toggle(name)
    end, { nargs = '?', desc = 'Toggle terminal' })

    vim.api.nvim_create_user_command('TermNew', function() core.new() end, { desc = 'Create new terminal' })
    vim.api.nvim_create_user_command('TermNext', function() core.next() end, { desc = 'Next terminal' })
    vim.api.nvim_create_user_command('TermPrev', function() core.prev() end, { desc = 'Previous terminal' })
    vim.api.nvim_create_user_command('TermClose', function() core.close() end, { desc = 'Close terminal' })
  end,
}
