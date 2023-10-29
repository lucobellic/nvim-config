return {
  'lucobellic/persistence.nvim',
  branch = 'personal',
  keys = {
    {
      '<leader>qr',
      function()
        require('persistence').load()
      end,
      desc = 'Restore session',
    },
    {
      '<leader>ql',
      function()
        require('persistence').load({ last = true })
      end,
      desc = 'Load last session',
    },
    {
      '<leader>qd',
      function()
        require('persistence').stop()
      end,
      desc = 'Stop session',
    },
    {
      '<leader>qs',
      function()
        require('persistence').save()
      end,
      desc = 'Save session',
    },
  },
  opts = {
    options = { 'buffers', 'curdir', 'tabpages', 'winpos', 'folds', 'winsize', 'help', 'globals', 'skiprtp' },
    pre_save = function()
      vim.cmd('tabmove 0')
      vim.cmd('ScopeSaveState')
    end,
  },
}
