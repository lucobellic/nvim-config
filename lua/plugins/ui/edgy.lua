-- vim.opt_local.winbar = '0, 0'
return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>wl',
      function() require('edgy').toggle('right') end,
      desc = 'Edgy Toggle Right',
    },
    {
      '<leader>wh',
      function() require('edgy').toggle('left') end,
      desc = 'Edgy Toggle Left',
    },
    {
      '<leader>wj',
      function() require('edgy').toggle('bottom') end,
      desc = 'Edgy Toggle Bottom',
    },
  },
  opts = {
    options = { bottom = { size = 0.25 } },
    close_when_all_hidden = false,
    exit_when_last = false,
    icons = {
      closed = '',
      open = '',
    },
    keys = {
      ['<c-left>'] = function(win) win:resize('width', 5) end,
      ['<c-up>'] = function(win) win:resize('height', 5) end,
      ['<c-right>'] = function(win) win:resize('width', -5) end,
      ['<c-down>'] = function(win) win:resize('height', -5) end,
    },
    wo = {
      winbar = false,
      spell = false,
    },
    right = {
      {
        title = 'copilot-chat',
        ft = 'copilot-chat',
        open = 'CopilotChat',
        size = { width = 0.20 },
      },
      {
        title = 'outline',
        ft = 'Outline',
        open = function() require('outline').toggle_outline() end,
        size = { width = 0.20 },
      },
      {
        title = 'trouble-lsp',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'lsp'
        end,
        open = 'Trouble lsp toggle focus=false win.position=right',
      },
      {
        title = 'trouble-symbols',
        ft = 'trouble',
        filter = function(_, win)
          local win_trouble = vim.w[win].trouble
          return win_trouble and win_trouble.mode == 'symbols'
        end,
        open = 'Trouble symbols toggle focus=false win.position=right',
      },
      {
        title = 'neotest-summary',
        ft = 'neotest-summary',
        open = 'Neotest summary',
        size = { width = 0.20 },
      }
    },
    bottom = {
      {
        title = 'toggleterm',
        ft = 'toggleterm',
        open = function()

          local buffers = vim.tbl_filter(
            function(buf) return vim.fn.bufname(buf.bufnr):find('toggleterm') ~= nil end,
            vim.fn.getbufinfo({ buflisted = 0, buftype = 'terminal' })
          )

          local toggleterm_open = #require('toggleterm.terminal').get_all(true) > 1
          local terminal_open = toggleterm_open or #buffers > 0

          -- Create a terminal if none exist, otherwise toggle all terminals
          if terminal_open then
            -- Toggle all terminal buffers with name containing 'toggleterm'
            vim.tbl_map(function(buf) vim.cmd('sbuffer ' .. buf.bufnr) end, buffers)
            if toggleterm_open then
              require('toggleterm').toggle_all()
            end
          else
            require('toggleterm').toggle()
          end
        end,
      },
      {
        title = 'toggleterm-tasks',
        ft = '',
        filter = function(buf)
          local is_term = vim.bo[buf].buftype == 'terminal'
          local is_toggleterm = vim.fn.bufname(buf):find('toggleterm')
          return is_term and is_toggleterm
        end,
        open = '',
      },
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
          return win_trouble and win_trouble.mode == 'qflist'
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
        title = 'noice',
        ft = 'noice',
        filter = function(buf, win)
          local is_not_floating = vim.api.nvim_win_get_config(win).relative == ''
          local is_no_file = vim.bo[buf].buftype == 'nofile'
          return is_no_file and is_not_floating
        end,
        open = 'Noice',
      },
      {
        title = 'neotest-panel',
        ft = 'neotest-output-panel',
        size = { height = 0.25 },
        open = 'Neotest output-panel',
      },
      {
        title = 'overseer',
        ft = 'OverseerList',
        open = 'OverseerToggle!',
        size = { width = 0.15 },
      },
    },
    animate = {
      enabled = false,
      cps = 300,
      spinner = {
        frames = { '', '', '', '', '', '' },
      },
    },
  },
}
