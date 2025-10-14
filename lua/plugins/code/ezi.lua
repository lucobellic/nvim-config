return {
  'nvim-treesitter/nvim-treesitter',
  opts = function(_, opts)
    vim.api.nvim_create_autocmd('User', {
      pattern = 'TSUpdate',
      callback = function()
        require('nvim-treesitter.parsers').ezi = {
          install_info = {
            path = '~/Development/tools/tree-sitter-ezi',
          },
          maintainers = { '@blaiselcq' },
        }
      end,
    })
    return opts
  end,
}
