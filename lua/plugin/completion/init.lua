local completion_plugins = {
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    {
        'hrsh7th/nvim-cmp',
        dependencies = { 'onsails/lspkind.nvim' },
        config = function()
            require('plugin.completion.comp')
        end
    },

    -- Snippets
    { 'saadparwaiz1/cmp_luasnip' },
    { 'rafamadriz/friendly-snippets' },
    {
        'L3MON4D3/LuaSnip',
        config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
        end
    },

    -- Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "VeryLazy",
        config = function()
            require("plugin.completion.copilot")
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end
    }
}

return completion_plugins
