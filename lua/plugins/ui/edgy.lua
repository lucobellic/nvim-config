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
        title = '  saga',
        ft = 'sagaoutline',
        pinned = true,
        open = 'SymbolsOutline',
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
-- return {
--   'folke/edgy.nvim',
--   enabled = false,
--   event = 'VeryLazy',
--   opts = {
--     icons = {
--       closed = '',
--       open = '',
--     },
--     wo = {
--       winbar = false,
--       winfixwidth = false,
--       winfixheight = false,
--     },
--     bottom = {
--       -- toggleterm / lazyterm at the bottom with a height of 40% of the screen
--       {
--         ft = "toggleterm",
--         size = { height = 0.2 },
--         -- exclude floating windows
--         filter = function(buf, win)
--           return vim.api.nvim_win_get_config(win).relative == ""
--         end,
--       },
--       {
--         ft = "lazyterm",
--         title = "LazyTerm",
--         size = { height = 0.2 },
--         filter = function(buf)
--           return not vim.b[buf].lazyterm_cmd
--         end,
--       },
--       "Trouble",
--       {
--         ft = "qf",
--         title = "QuickFix"
--       },
--       {
--         ft = "help",
--         size = { height = 20 },
--         -- only show help buffers
--         filter = function(buf)
--           return vim.bo[buf].buftype == "help"
--         end,
--       },
--       { ft = "spectre_panel", size = { height = 0.4 } },
--     },
--     left = {
--       -- Neo-tree filesystem always takes half the screen height
--       {
--         ft = "neo-tree",
--         filter = function(buf)
--           return vim.b[buf].neo_tree_source == "filesystem"
--         end,
--         size = { height = 0.5, width = 0.2 },
--       },
--       {
--         ft = "neo-tree",
--         filter = function(buf)
--           return vim.b[buf].neo_tree_source == "git_status"
--         end,
--         pinned = false,
--         open = "Neotree position=right git_status",
--       },
--       {
--         ft = "neo-tree",
--         filter = function(buf)
--           return vim.b[buf].neo_tree_source == "buffers"
--         end,
--         pinned = false,
--         open = "Neotree position=top buffers",
--       },
--       -- any other neo-tree windows
--       "neo-tree",
--     },
--     right = {
--       {
--         ft = "Outline",
--         pinned = false,
--         open = "SymbolsOutline",
--       },
--       {
--         ft = 'OverseerList',
--         open = 'OverseerOpen',
--       }
--     }
--   }
-- }
