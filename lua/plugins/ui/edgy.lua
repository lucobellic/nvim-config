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
    },
    right = {
      {
        title = 'outline',
        pinned = true,
        ft = 'Outline',
        open = 'OutlineOpen',
      },
      {
        title = 'overseer',
        pinned = true,
        ft = 'OverseerList',
        open = 'OverseerOpen',
      },
    },
    left = {
      -- {
      --   title = "Neo-Tree",
      --   ft = "neo-tree",
      --
      --   filter = function(buf)
      --     return vim.b[buf].neo_tree_source == "filesystem"
      --   end,
      --   size = { height = 0.5 },
      -- },
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
        title = 'spectre',
        ft = 'spectre_panel',
        open = 'Spectre',
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
