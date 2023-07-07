local lsp_plugins = {
  {
    'folke/neodev.nvim',
    opts =
    {
      library = {
        plugins = { 'nvim-dap-ui', 'neotest' },
        types = true
      },
    }
  },
  {
    'williamboman/mason.nvim',
    opts = {
      PATH = 'prepend',
      ui = {
        border = 'rounded',
        width = 0.8,
        height = 0.8
      }
    }
  },
  {
    'williamboman/mason-lspconfig.nvim',
    event = 'VeryLazy',
    opts = {
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
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'davidmh/cspell.nvim',
    },
    opts = require('plugins.lsp.config.null-ls')
  },
  require('plugins.lsp.navbuddy'),
  {
    'neovim/nvim-lspconfig',
    opts = {
      -- Enable nvim-ufo capabilities
      capabilities = {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
      inlay_hints = {
        enabled = true,
      },
      servers = {
        clangd = require('plugins.lsp.config.clangd'),
        pylsp = require('plugins.lsp.config.pylsp')
      },
      diagnostics = require('plugins.lsp.config.misc')
    },
    init = require('plugins.lsp.config.keymaps')
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
