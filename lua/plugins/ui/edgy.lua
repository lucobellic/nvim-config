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
        title = 'chatgpt',
        ft = 'markdown',
        filter = function(buf, win) return vim.bo[buf].buftype == 'prompt' end,
        open = 'GpChatToggle',
        size = { width = 0.25 },
      },
      {
        title = 'outline',
        ft = 'Outline',
        open = 'OutlineOpen',
      },
      {
        title = 'overseer',
        ft = 'OverseerList',
        open = 'OverseerOpen',
        size = { height = 0.15 },
      },
      {
        title = 'neotest-summary',
        ft = 'neotest-summary',
        open = 'Neotest summary',
        size = { width = 0.15 },
      },
    },
    left = {
      --   {
      --     title = 'Neo-Tree Filesystem',
      --     ft = 'neo-tree',
      --     filter = function(buf) return vim.b[buf].neo_tree_source == 'filesystem' end,
      --     pinned = true,
      --     open = 'Neotree position=top filesystem',
      --   },
      --   {
      --     title = 'Neo-Tree Buffers',
      --     ft = 'neo-tree',
      --     filter = function(buf) return vim.b[buf].neo_tree_source == 'buffers' end,
      --     pinned = true,
      --     open = 'Neotree position=left buffers',
      --   },
      --   {
      --     title = 'Neo-Tree Git',
      --     ft = 'neo-tree',
      --     filter = function(buf) return vim.b[buf].neo_tree_source == 'git_status' end,
      --     pinned = true,
      --     open = 'Neotree position=left git_status',
      --   },
    },
    bottom = {
      {
        title = 'toggleterm',
        ft = 'toggleterm',
        open = 'ToggleTermToggleAll',
      },
      {
        title = 'trouble',
        ft = 'Trouble',
        open = 'Trouble',
      },
      {
        title = 'neotest-panel',
        ft = 'neotest-output-panel',
        size = { height = 0.25 },
        open = 'Neotest output-panel',
      },
    },
    animate = {
      enabled = not vim.g.neovide,
      cps = 300,
      spinner = {
        frames = { '', '', '', '', '', '' },
      },
    },
  },
}
