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
        title = 'overseer',
        ft = 'OverseerList',
        open = 'OverseerToggle! right',
        size = { width = 0.20, height = 0.15 },
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
        title = 'trouble',
        ft = 'Trouble',
        open = 'TroubleToggle',
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
