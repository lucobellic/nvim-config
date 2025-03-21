return {
  'folke/edgy.nvim',
  opts = {
    left = {
      {
        title = 'trouble-symbols',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'symbols'
        end,
        open = 'Trouble symbols toggle focus=false win.position=left',
      },
    },
    right = {
      {
        title = 'trouble-lsp',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'lsp'
        end,
        open = 'Trouble lsp toggle focus=false win.position=right',
      },
    },
    bottom = {
      {
        title = 'trouble-telescope',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'telescope'
        end,
        open = 'Trouble telescope toggle',
      },
      {
        title = 'trouble-snacks',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'snacks'
        end,
        open = 'Trouble snacks toggle',
      },
      {
        title = 'trouble-snacks-files',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'snacks_files'
        end,
        open = 'Trouble snacks_files toggle',
      },
      {
        title = 'trouble-lsp-definitions',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'lsp_definitions'
        end,
        open = 'Trouble lsp_definitions toggle restore=true',
      },
      {
        title = 'trouble-lsp-references',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'lsp_references'
        end,
        open = 'Trouble lsp_references toggle restore=true',
      },
      {
        title = 'trouble-diagnostics',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'diagnostics'
        end,
        open = 'Trouble diagnostics toggle filter.buf=0',
      },
      {
        title = 'trouble-qflist',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and (win_trouble.mode == 'qflist' or win_trouble.mode == 'quickfix')
        end,
        open = 'Trouble qflist toggle',
      },
      {
        title = 'trouble-loclist',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'loclist'
        end,
        open = 'Trouble loclist toggle',
      },
      {
        title = 'trouble-todo',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'todo'
        end,
        open = 'Trouble loclist toggle',
      },
      {
        title = 'quickfix',
        ft = 'qf',
      },
    },
  },
}
