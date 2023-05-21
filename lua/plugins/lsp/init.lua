local lsp_plugins = {
  {
    'folke/neodev.nvim',
    event = "VeryLazy",
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
    event = 'VeryLazy',
    config = function()
      require('mason').setup({
        PATH = 'prepend',
        ui = {
          border = 'rounded',
          width = 0.8,
          height = 0.8
        }
      })
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    event = 'VeryLazy',
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
    event = 'VeryLazy',
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
    event = 'VeryLazy',
    opts = {
      show_guides = false,
      fold_markers = { '', '' },
    }
  },
  {
    'ErichDonGubler/lsp_lines.nvim',
    name = 'lsp_lines',
    event = 'VeryLazy',
    config = function()
      require("lsp_lines").setup()
    end,
  },
  { 'jose-elias-alvarez/null-ls.nvim', event = 'VeryLazy' },
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      'folke/neodev.nvim',
      'lsp_lines',
      'hrsh7th/nvim-cmp'
    },
    config = function()
      require('plugins.lsp.config.servers')
      require('plugins.lsp.config.null-ls')
      require('plugins.lsp.config.misc')
    end
  },

  -- Code documentation
  {
    'danymat/neogen',
    event = 'VeryLazy',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('neogen').setup({
        snippet_engine = 'luasnip',
        input_after_comment = false,
        languages = {
          python = {
            template = {
              annotation_convention = 'numpydoc',
            }
          }
        }
      })
    end,
  },

  -- Refactoring
  {
    'ThePrimeagen/refactoring.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('refactoring').setup({})
    end
  }
}

return lsp_plugins
