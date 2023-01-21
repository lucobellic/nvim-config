local editor_plugins = {
    { 'folke/zen-mode.nvim', config = function() require('plugin.editor.zenmode') end },
    { 'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'limelight.vim') end }, -- Highlight paragraph
    { 'luochen1990/rainbow', config = function() vim.cmd('source ' .. config_path .. '/' .. 'rainbow.vim') end },

    -- use term as in editor
    { 'chomosuke/term-edit.nvim',
        config = function() require('plugin.editor.term-edit') end
    },

    -- smooth scroll
    { 'karb94/neoscroll.nvim', config = function() require('plugin.editor.neoscroll') end },

    { 'echasnovski/mini.indentscope', branch = 'stable', config = function() require('plugin.editor.indentscope') end },
    { 'sindrets/diffview.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function() require('plugin.editor.diffview') end
    },
}

return editor_plugins
