local lsp_plugins = {
    {
        'folke/neodev.nvim',
        config = function()
            -- Enable type checking for nvim-dap-ui to get type checking, documentation and autocompletion for all API functions.
            require('neodev').setup({ library = { plugins = { 'nvim-dap-ui' }, types = true }, })
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
            require('plugin.lsp.saga')
        end
    },
    {
        'simrat39/symbols-outline.nvim',
        config = function()
            require('symbols-outline').setup()
        end
    },
    { 'jose-elias-alvarez/null-ls.nvim' },
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'folke/neodev.nvim' },
        config = function()
            require('plugin.lsp.config')
        end
    },
}

return lsp_plugins
