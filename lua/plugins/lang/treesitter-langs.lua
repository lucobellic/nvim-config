-- Rapidash Tree-sitter grammars.
-- nvim-treesitter cannot download GitLab archives, so lazy.nvim clones the repo.
-- User TSUpdate must stay cheap. LazyVim installs ensure_installed asynchronously.

local function grammar_root()
  local ok, lazy_config = pcall(require, 'lazy.core.config')
  if ok then
    local plugin = lazy_config.plugins['tree-sitter-rapidash']
    if plugin and plugin.dir then
      return plugin.dir
    end
  end
  return vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'tree-sitter-rapidash')
end

---@param location string
---@return table
local function parser_spec(location)
  return {
    install_info = {
      path = grammar_root(),
      location = location,
      queries = location .. '/queries',
    },
  }
end

if not vim.env.INSIDE_DOCKER then
  return {}
end

return {
  {
    url = 'git@gitlab.easymile.com:ludovic.hussonnois/tree-sitter-rapidash.git',
    name = 'tree-sitter-rapidash',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'tree-sitter-rapidash' },
    init = function()
      vim.treesitter.language.register('ros2', { 'ros' })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = function()
          local parsers = require('nvim-treesitter.parsers')
          parsers.ezcan = parser_spec('ezcan')
          parsers.ezi = parser_spec('ezi')
        end,
      })
    end,
    opts = {
      ensure_installed = { 'ezcan', 'ezi' },
    },
  },
}
