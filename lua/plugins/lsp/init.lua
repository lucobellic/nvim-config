local lsp_plugins = {
  {
    'folke/neodev.nvim',
    config = function()
      -- Enable type checking for nvim-dap-ui to get type checking, documentation and autocompletion for all API functions.
      require('neodev').setup({
        library = {
          plugins = { 'nvim-dap-ui', 'neotest' },
          types = true
        },
      })
    end
  },
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'jsonls',
          'vimls',
          'cmake',
          'lua_ls',
          'rust_analyzer',
          'pylsp',
          'pyright',
          'clangd',
        },
        automatic_installation = true,
      }
    end
  },
  {
    'glepnir/lspsaga.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
      { 'nvim-treesitter/nvim-treesitter' }
    },
    config = function()
      require('plugins.lsp.saga')
    end
  },
  {
    'simrat39/symbols-outline.nvim',
    opts = {
      show_guides = false,
      fold_markers = { '', '' },
    }
  },
  {
    'ErichDonGubler/lsp_lines.nvim',
    name = 'lsp_lines',
    config = function()
      require("lsp_lines").setup()
    end,
  },
  { 'jose-elias-alvarez/null-ls.nvim' },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'folke/neodev.nvim', 'lsp_lines' },
    config = function()
      require('plugins.lsp.config.servers')
      require('plugins.lsp.config.null-ls')
      require('plugins.lsp.config.misc')
    end
  },

  -- Code documentation
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('neogen').setup({
        snippet_engine = 'luasnip',
        input_after_comment = false,
      })
    end,
  },

  -- Refactoring
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('refactoring').setup({})
    end
  }
}

return lsp_plugins