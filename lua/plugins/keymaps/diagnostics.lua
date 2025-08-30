return {
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>ud', group = 'Diagnostics' },
      },
    },
  },
  {
    'folke/which-key.nvim',
    keys = {
      {
        '<leader>udd',
        function() vim.cmd('ToggleDiagnosticVirtualText') end,
        repeatable = true,
        desc = 'Toggle Virtual Text',
      },
      {
        '<leader>udl',
        function() vim.cmd('ToggleDiagnosticVirtualLines') end,
        repeatable = true,
        desc = 'Toggle Virtual Lines',
      },
      {
        '<leader>udu',
        function() vim.cmd('ToggleDiagnosticsUnderline') end,
        repeatable = true,
        desc = 'Toggle Diagnostics Underline',
      },
      {
        '<leader>udt',
        function() vim.cmd('ToggleDiagnostics') end,
        repeatable = true,
        desc = 'Toggle Diagnostics',
      },
      { '>S', ']s', remap = true, desc = 'Next Spelling' },
      { '<S', '[s', remap = true, desc = 'Prev Spelling' },
      { '>D', ']d', remap = true, desc = 'Next Diagnostic' },
      { '<D', '[d', remap = true, desc = 'Prev Diagnostic' },
      { '>W', ']w', remap = true, desc = 'Next Warning' },
      { '<W', '[w', remap = true, desc = 'Prev Warning' },
      { '>E', ']e', remap = true, desc = 'Next Error' },
      { '<E', '[e', remap = true, desc = 'Prev Error' },
    },
  },
}
