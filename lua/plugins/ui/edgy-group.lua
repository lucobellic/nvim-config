return {
  url = 'git@github.com:lucobellic/edgy-group.nvim.git',
  dependencies = { 'folke/edgy.nvim' },
  keys = {
    {
      '<leader>el',
      function() vim.cmd('EdgyGroupNext right') end,
      desc = 'Edgy Group Next Right',
      repeatable = true,
    },
    {
      '<leader>eh',
      function() vim.cmd('EdgyGroupPrev right') end,
      desc = 'Edgy Group Prev Right',
      repeatable = true,
    },
  },
  opts = {
    hide = true,
    groups = {
      { title = '', pos = 'right', filetypes = { 'Outline' } },
      { title = '', pos = 'right', filetypes = { 'OverseerList' } },
    },
  },
  dev = true,
}
