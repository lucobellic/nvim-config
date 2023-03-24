local editor_plugins = {
    { 'folke/zen-mode.nvim',    config = function() require('plugin.editor.zenmode') end },
    { 'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'limelight.vim') end }, -- Highlight paragraph
    { 'luochen1990/rainbow',    config = function() vim.cmd('source ' .. config_path .. '/' .. 'rainbow.vim') end },

    -- use term as in editor
    {
        'chomosuke/term-edit.nvim',
        config = function() require('plugin.editor.term-edit') end
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require('plugin.editor.indent-blankline')
        end
    },
    {
        'echasnovski/mini.indentscope',
        branch = 'stable',
        config = function()
            require('plugin.editor.indentscope')
        end
    },
    {
        'sindrets/diffview.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function() require('plugin.editor.diffview') end
    },
    {
        'kevinhwang91/nvim-ufo',
        dependencies = { 'kevinhwang91/promise-async' },
        config = function() require('plugin.editor.fold') end
    },
    {
        'echasnovski/mini.splitjoin',
        config = function()
            require('mini.splitjoin').setup({
                mappings = {
                    toggle = '<leader>S',
                    split = '',
                    join = '',
                },
            })
        end
    },
    {
        'echasnovski/mini.move',
        version = '*',
        config = function()
            require('mini.move').setup({})
        end
    },
    {
        'windwp/nvim-spectre',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function() require('plugin.editor.spectre') end
    },
    {
        'RRethy/vim-illuminate',
        enabled = true,
        config = function() require('plugin.editor.illuminate') end
    },
}

return editor_plugins
