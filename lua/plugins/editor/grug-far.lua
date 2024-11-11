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
    { '<leader>s;', function() require('grug-far').open({}) end, desc = 'GrugFar' },
    {
      '<leader>s;',
      function()
        require('grug-far').with_visual_selection({
          prefills = {
            search = vim.fn.expand('<cword>'),
            filesFilter = vim.fn.expand('%'),
          },
        })
      end,
      mode = 'v',
      desc = 'GrugFar',
    },
  },
}
