return {
  'Isrothy/neominimap.nvim',
  version = 'v3.*.*',
  event = 'VeryLazy',
  keys = {
    { '<leader>uM', '<cmd>Neominimap toggle<CR>', desc = 'Toggle minimap' },
  },
  init = function()
    vim.g.neominimap = {
      auto_enable = false,
      layout = 'float',
      split = {
        fix_width = true,
      },
      float = {
        window_border = 'none',
      },
      diagnostic = {
        ---@type Neominimap.Handler.Annotation.Mode
        mode = 'sign',
      },
    }
  end,
  config = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'FoldChanged',
      callback = function() require('neominimap.api').refresh() end,
    })

    vim.api.nvim_create_autocmd('WinLeave', {
      callback = function()
        require('neominimap.api').win.disable()
      end,
      desc = 'Disable neominimap when leaving buffer',
    })

    vim.api.nvim_create_autocmd('WinEnter', {
      callback = function()
        require('neominimap.api').win.enable()
      end,
      desc = 'Enable neominimap when entering buffer',
    })
  end,
}
