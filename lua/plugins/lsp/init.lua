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
      require('plugins.lsp.config')
    end
  },
}

return lsp_plugins
