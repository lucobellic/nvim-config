local util = require('util.persistence')

return {
  'lucobellic/persistence.nvim',
  branch = 'personal',
  event = 'VeryLazy',
  keys = {
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
    options = { 'buffers', 'curdir', 'tabpages', 'winpos', 'folds', 'winsize', 'help', 'globals', 'skiprtp' },
    pre_save = util.pre_save,
  },
  config = function(_, opts)
    local persistence = require('persistence')
    persistence.setup(opts)

    -- Save current directory on exit
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function() persistence.save() end,
    })

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
