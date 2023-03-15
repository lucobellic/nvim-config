local lsp_plugins = {
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
    { 'jose-elias-alvarez/null-ls.nvim' },
    {
        'neovim/nvim-lspconfig',
        config = function()
            require('plugin.lsp.config')
        end
    },
}

return lsp_plugins
