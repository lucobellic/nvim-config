---@param dir string
---@param location string
---@return table
local function parser_spec(dir, location)
  return {
    install_info = {
      path = dir,
      location = location,
      queries = location .. '/queries',
    },
  }
end

return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    {
      url = '',
      name = 'tree-sitter-rapidash',
      init = function(plugin)
        vim.treesitter.language.register('ros2', { 'ros' })
        vim.api.nvim_create_autocmd('User', {
          pattern = 'TSUpdate',
          callback = function()
            local parsers = require('nvim-treesitter.parsers')
            parsers.ezcan = parser_spec(plugin.dir, 'ezcan')
            parsers.ezi = parser_spec(plugin.dir, 'ezi')
          end,
        })
      end,
    },
  },
}
