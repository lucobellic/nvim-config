return {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    autojump = true,
    keymaps = {
      ['<C-j>'] = false,
      ['<C-k>'] = false,
    },
  }
}
