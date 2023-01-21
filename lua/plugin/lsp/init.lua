local lsp_plugins = {
    { 'williamboman/mason.nvim', config = function() require('mason').setup() end },
    { 'williamboman/mason-lspconfig.nvim',
        config = function()
                require('mason-lspconfig').setup { ensure_installed = {
                    'jsonls',
                    'vimls',
                    'cmake',
                    'sumneko_lua',
                    'rust_analyzer',
                    'pylsp',
                    'pyright',
                    'yapf',
                    'clangd'
                }}
        end
    },

    { 'glepnir/lspsaga.nvim', config = function() require('plugin.lsp.saga') end },

    --  native nvim lsp
    { 'theHamsta/nvim-semantic-tokens', config = function() require('plugin.lsp.tokens') end },
    { 'neovim/nvim-lspconfig',
        dependencies = { 'nvim-semantic-tokens' },
        config = function()
            require('plugin.lsp.config')
        end
    },
}

return lsp_plugins
