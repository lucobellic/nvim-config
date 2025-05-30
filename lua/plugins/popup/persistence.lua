return {
  'folke/persistence.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'tiagovla/scope.nvim',
      version = '*',
      opts = {
        restore_state = true,
      },
    },
  },
  keys = {
    {
      '<leader>fs',
      function() require('util.persistence').select_session() end,
      desc = 'Find Sessions',
    },
    {
      '<leader>qr',
      function() require('persistence').load() end,
      desc = 'Restore session',
    },
    {
      '<leader>ql',
      function() require('persistence').load({ last = true }) end,
      desc = 'Load last session',
    },
    {
      '<leader>qd',
      function() require('persistence').stop() end,
      desc = 'Stop session',
    },
    {
      '<leader>qs',
      function() require('persistence').save() end,
      desc = 'Save session',
    },
  },
  opts = {
    branch = false, -- use git branch to save session
  },
  config = function(_, opts)
    local persistence = require('persistence')
    local util = require('util.persistence')
    persistence.setup(opts)

    -- Save current directory on exit
    vim.api.nvim_create_autocmd('VimLeavePre', { callback = function() persistence.save() end })
    vim.api.nvim_create_autocmd('User', { pattern = 'PersistenceSavePre', callback = function() util.pre_save() end })

    -- Load session from persistence
    vim.api.nvim_create_user_command(
      'PersistenceLoadSession',
      function() require('util.persistence').select_session() end,
      {}
    )
    vim.api.nvim_create_user_command(
      'PersistenceLoadLast',
      function() require('persistence').load({ last = true }) end,
      {}
    )
  end,
}
