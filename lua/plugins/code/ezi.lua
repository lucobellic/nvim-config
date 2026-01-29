local function git_latest(url)
  local path = vim.fn.stdpath('data') .. '/tree-sitter-ezi'
  local is_installed = vim.fn.isdirectory(path) == 1
  local command = is_installed and { 'git', '-C', path, 'pull' } or { 'git', 'clone', url, path }
  vim.fn.system(command)
  return path
end

return {
  'nvim-treesitter/nvim-treesitter',
  opts = function(_, opts)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'TSUpdate',
      callback = function()
        require('nvim-treesitter.parsers').ezi = {
          install_info = {
            path = git_latest('git@gitlab.easymile.com:blaiselcq/tree-sitter-ezi'),
            queries = 'queries',
          },
          maintainers = { '@blaiselcq' },
        }
      end,
    })
    return opts
  end,
}
