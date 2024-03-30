-- vim.opt_local.winbar = '0, 0'
return {
  'folke/edgy.nvim',
  enabled = not vim.g.started_by_firenvim,
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
        title = 'chatgpt',
        ft = 'markdown',
        filter = function(buf, win)
          local is_not_floating = vim.api.nvim_win_get_config(win).relative == ''
          local is_prompt = vim.bo[buf].buftype == 'prompt'
          return is_prompt and is_not_floating
        end,
        open = 'GpChatToggle',
        size = { width = 0.40 },
      },
      {
        title = 'copilot-chat',
        ft = 'markdown',
        filter = function(buf, win)
          local is_not_floating = vim.api.nvim_win_get_config(win).relative == ''
          local filename = vim.fn.fnamemodify(vim.fn.bufname(buf), ':t')
          return is_not_floating and filename == 'copilot-chat'
        end,
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
      },
      {
        title = 'OGPT Parameters',
        ft = 'ogpt-parameters-window',
        size = { height = 0.15 },
        wo = { wrap = true },
        open = '',
      },
      {
        title = 'OGPT Template',
        ft = 'ogpt-template',
        size = { height = 0.15 },
        open = '',
      },
      {
        title = 'OGPT Sessions',
        ft = 'ogpt-sessions',
        size = { height = 0.15 },
        wo = { wrap = true },
        open = '',
      },
      {
        title = 'OGPT System Input',
        ft = 'ogpt-system-window',
        size = { height = 0.15 },
        open = '',
      },
      {
        title = 'OGPT',
        ft = 'ogpt-window',
        size = { height = 0.5 },
        wo = { wrap = true },
        open = 'OGPT',
      },
      {
        title = 'OGPT Selection',
        ft = 'ogpt-selection',
        size = { width = 0.20, height = 0.15 },
        wo = { wrap = true },
        open = '',
      },
      {
        title = 'OGPT Instruction',
        ft = 'ogpt-instruction',
        size = { width = 0.20, height = 0.15 },
        wo = { wrap = true },
        open = '',
      },
      {
        title = 'OGPT Chat',
        ft = 'ogpt-input',
        size = { width = 0.20, height = 4 },
        wo = { wrap = true },
        open = '',
      },
    },
    bottom = {
      {
        title = 'toggleterm',
        ft = 'toggleterm',
        open = function()
          -- Create a terminal if none exist, otherwise toggle all terminals
          if #require('toggleterm.terminal').get_all(true) > 1 then
            require('toggleterm').toggle_all()
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
        title = 'overseer',
        ft = 'OverseerList',
        open = 'OverseerToggle!',
        size = { width = 0.15 },
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
