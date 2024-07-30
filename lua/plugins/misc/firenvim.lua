return {
  'glacambre/firenvim',
  -- Lazy load firenvim
  -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
  lazy = false,
  cond = not not vim.g.started_by_firenvim,
  build = function()
    require('lazy').load({ plugins = 'firenvim', wait = true })
    vim.fn['firenvim#install'](0)
  end,
  config = function()
    vim.o.guifont = 'DMMono Nerd Font:h10'
    vim.g.firenvim_config = {
      globalSettings = {
        alt = 'all',
      },
      localSettings = {
        ['.*'] = {
          cmdline = 'neovim',
          content = 'text',
          priority = 0,
          selector = 'textarea',
          takeover = 'never',
        },
      },
    }
  end,
}
