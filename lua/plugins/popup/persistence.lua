return {
  'folke/persistence.nvim',
  opts = {
    options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
    pre_save = function() vim.api.nvim_exec_autocmds('User', { pattern = 'SessionSavePre' }) end
  }
}
