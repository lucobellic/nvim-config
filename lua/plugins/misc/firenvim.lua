return {
  'glacambre/firenvim',
  -- Lazy load firenvim
  -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
  lazy = false,
  cond = not not vim.g.started_by_firenvim,
  build = function()
    require('lazy').load({ plugins = { 'firenvim' }, wait = true })
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

    -- Resize minimum window height and width on buffer enter
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = '*',
      callback = function()
        local win_height = vim.api.nvim_win_get_height(0)
        local win_width = vim.api.nvim_win_get_width(0)
        if win_height < 12 then
          vim.opt.lines = 12
        end

        if win_width < 80 then
          vim.opt.columns = 80
        end
      end,
      desc = 'Set minimum window height and width on buffer enter',
    })
  end,
}
