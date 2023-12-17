-- vim.opt_local.winbar = '0, 0'
return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>wl',
      function()
        require('edgy').toggle('right')
      end,
      desc = 'Edgy Close Right',
    },
    {
      '<leader>wh',
      function()
        require('edgy').toggle('left')
      end,
      desc = 'Edgy Close Left',
    },
  },
  opts = {
    close_when_all_hidden = false,
    icons = {
      closed = '',
      open = '',
    },
    keys = {
      -- increase width
      ['<c-left>'] = function(win)
        win:resize('width', 5)
      end,
      -- decrease width
      ['<c-right>'] = function(win)
        win:resize('width', -5)
      end,
    },
    right = {
      {
        title = '  outline',
        ft = 'Outline',
        pinned = true,
        open = 'OutlineOpen'
      },
      {
        title = ' ',
        ft = 'OverseerList',
        pinned = true,
        open = 'OverseerOpen',
      },
    },
    left = {
      -- {
      --   title = "Neo-Tree",
      --   ft = "neo-tree",
      --   pinned = true,
      --   filter = function(buf)
      --     return vim.b[buf].neo_tree_source == "filesystem"
      --   end,
      --   size = { height = 0.5 },
      -- },
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
