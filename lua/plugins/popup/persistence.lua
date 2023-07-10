return {
  'folke/persistence.nvim',
  keys = {
    { '<leader>qr', function() require("persistence").load() end,                desc = 'Restore session' },
    { '<leader>ql', function() require("persistence").load({ last = true }) end, desc = 'Load last session' },
    { '<leader>qd', function() require("persistence").stop() end,                desc = 'Stop session' },
    { '<leader>qs', ':PersistenceLoadSession<cr>',                               desc = 'Load session' },
  },
  opts = {
    options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
    pre_save = function() vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' }) end
  }
}
