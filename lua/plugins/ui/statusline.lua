return {
  dir = vim.fn.stdpath('config') .. '/local/statusline',
  name = 'statusline',
  lazy = false,
  config = function()
    local components = require('statusline.components')

    -- Load only the small status helper rather than starting optional plugins.
    if package.loaded.lazy then
      require('lazy.status')
    end

    require('statusline.events').setup()
    require('statusline').setup({
      left = components.left,
      center = components.center,
      right = components.right,
      highlight = 'UserStatuslineBase',
    })
  end,
}
