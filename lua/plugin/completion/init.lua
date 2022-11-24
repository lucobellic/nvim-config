return { config = function(use)
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/cmp-path' }
    use { 'hrsh7th/cmp-cmdline' }
    use { 'hrsh7th/nvim-cmp', requires = { 'onsails/lspkind.nvim' },
        config = function()
            require('plugin.completion.comp')
        end
    }

    use { 'L3MON4D3/LuaSnip', module = 'luasnip' } -- Snippet engine
    use { 'saadparwaiz1/cmp_luasnip' }
end
}
