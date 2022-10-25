return { config = function(use)
    use { 'williamboman/mason.nvim', config = function() require('mason').setup() end }
    use { 'williamboman/mason-lspconfig.nvim', config = function() require('mason-lspconfig').setup() end }

    -- Use native nvim lsp
    use { 'theHamsta/nvim-semantic-tokens', config = function() require('plugin.lsp.tokens') end }
    use { 'neovim/nvim-lspconfig', after = 'nvim-semantic-tokens', config = function() require('plugin.lsp.config') end }

    use { 'glepnir/lspsaga.nvim', config = function() require('plugin.lsp.saga') end }

end
}
