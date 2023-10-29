local function restore_yank_register_after_paste()
  local prev = vim.fn.getreg('0')
  vim.fn.setreg('"', prev)
  vim.fn.setreg('*', prev)
  vim.fn.setreg('+', prev)
end

return {
  'gbprod/yanky.nvim',
  keys = {
    { '<leader>p', false },
    {
      'p',
      function()
        vim.cmd('execute "normal \\<Plug>(YankyPutAfter)"')
        restore_yank_register_after_paste()
      end,
      mode = { 'n', 'x' },
      desc = 'Put yanked text after cursor',
    },
    {
      'P',
      function()
        vim.cmd('execute "normal \\<Plug>(YankyPutBefore)"')
        restore_yank_register_after_paste()
      end,
      mode = { 'n', 'x' },
      desc = 'Put yanked text after cursor',
    },
    {
      '<leader>fy',
      function()
        require('telescope').extensions.yank_history.yank_history({})
      end,
      desc = 'Open Yank History',
    },
    { '<leader>=p', false },
    { '<leader>=P', false },
  },
}
