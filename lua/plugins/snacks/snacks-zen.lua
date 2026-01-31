ZenMode = {
  dropbar_disabled = vim.g.dropbar_disabled,
  foldcolumn = vim.opt.foldcolumn,
  laststatus = vim.opt.laststatus,
  showtabline = vim.opt.showtabline,
  statusline = vim.opt.statusline,
  winbar = vim.opt.winbar,
}

function ZenMode.store()
  ZenMode.dropbar_disabled = vim.g.dropbar_disabled
  ZenMode.foldcolumn = vim.opt.foldcolumn
  ZenMode.laststatus = vim.opt.laststatus
  ZenMode.showtabline = vim.opt.showtabline
  ZenMode.statusline = vim.opt.statusline
  ZenMode.winbar = vim.opt.winbar
end

function ZenMode.restore()
  vim.g.dropbar_disabled = ZenMode.dropbar_disabled
  vim.opt.foldcolumn = ZenMode.foldcolumn
  vim.opt.laststatus = ZenMode.laststatus
  vim.opt.showtabline = ZenMode.showtabline
  vim.opt.statusline = ZenMode.statusline
  vim.opt.winbar = ZenMode.winbar
end

function ZenMode.apply()
  vim.g.zen_mode = true
  ZenMode.store()
  require('incline').disable()
  vim.cmd('SatelliteDisable')
  vim.g.dropbar_disabled = true
  vim.opt.foldcolumn = '0'
  vim.opt.laststatus = 0
  vim.opt.showtabline = 0
  vim.opt.statusline = ' '
  vim.opt.winbar = ''
end

function ZenMode.toggle()
  vim.g.zen_mode = not vim.g.zen_mode
  if vim.g.zen_mode then
    ZenMode.apply()
  else
    ZenMode.restore()
  end
end

return {
  'snacks.nvim',
  keys = {
    { '<c-z>', function() require('snacks.zen').zen() end, desc = 'Toggle Zen Mode' },
    { '<leader>zz', function() require('snacks.zen').zen() end, desc = 'Toggle Zen Mode' },
    { '<leader>zm', function() require('snacks.zen').zoom() end, desc = 'Toggle Zoom Mode' },
    {
      '<leader>zs',
      function() ZenMode.toggle() end,
      desc = 'Toggle All Status Bar',
    },
    {
      '<leader>uD',
      function()
        local dim = require('snacks.dim')
        if dim.enabled then
          dim.disable()
        else
          dim.enable()
        end
      end,
      desc = 'Toggle Dim Mode',
    },
  },
  opts = {
    spec = { { '<leader>z', group = 'zen' } },
    styles = {
      fullzen = {
        enter = true,
        fixbuf = false,
        minimal = false,
        width = 120,
        height = 0,
        backdrop = { transparent = false, blend = 99 },
        keys = { q = false },
        zindex = 40,
        w = { snacks_main = true },
      },
    },
    zen = {
      enabled = true,
      win = { style = 'fullzen' },
    },
  },
}
