local editor_plugins = {
    { 'folke/zen-mode.nvim', config = function() require('plugin.editor.zenmode') end },
    { 'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'limelight.vim') end }, -- Highlight paragraph
    { 'luochen1990/rainbow', config = function() vim.cmd('source ' .. config_path .. '/' .. 'rainbow.vim') end },

    -- smooth scroll
    { 'karb94/neoscroll.nvim', config = function() require('plugin.editor.neoscroll') end },

    { 'lukas-reineke/indent-blankline.nvim', config = function() require('plugin.editor.indent') end },
    { 'sindrets/diffview.nvim',
        dependencies = {'nvim-lua/plenary.nvim' } ,
        config = function() require('plugin.editor.diffview') end
    },
}

return editor_plugins
