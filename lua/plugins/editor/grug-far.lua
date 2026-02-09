return {
  'MagicDuck/grug-far.nvim',
  opts = {
    resultsSeparatorLineChar = '-',
    spinnerStates = { '', '', '', '' },
    startInInsertMode = false,
    icons = {
      resultsStatusReady = ' ',
      resultsStatusError = ' ',
      resultsStatusSuccess = ' ',
      resultsActionMessage = '  ',
      resultsChangeIndicator = '│',
      historyTitle = '  ',
    },
    engines = {
      ripgrep = {
        placeholders = {
          enabled = false,
        },
      },
    },
    disableBufferLineNumbers = true,
  },
  keys = {
    { '<leader>sR', function() require('grug-far').open({}) end, desc = 'GrugFar All Files' },
    {
      '<leader>sR',
      function()
        require('grug-far').with_visual_selection({
          prefills = { search = vim.fn.expand('<cword>') },
        })
      end,
      mode = 'v',
      desc = 'GrugFar Visual All Files',
    },
    {
      '<leader>sr',
      function()
        require('grug-far').open({
          prefills = { filesFilter = vim.fn.expand('%') },
        })
      end,
      desc = 'GrugFar Current File',
    },
    {
      '<leader>sr',
      function()
        require('grug-far').with_visual_selection({
          prefills = {
            search = vim.fn.expand('<cword>'),
            filesFilter = vim.fn.expand('%'),
          },
        })
      end,
      mode = 'v',
      desc = 'GrugFar Visual Current File',
    },
  },
}
