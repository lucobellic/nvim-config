local navigation_plugins = {
    { 'junegunn/fzf',     run = 'fzf#install()' },
    { 'junegunn/fzf.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'fzf.vim') end },
    {
        'phaazon/hop.nvim',
        branch = 'v2',
        config = function()
            require('plugin.navigation.hop')
        end
    },
    'tpope/vim-sensible',
    'tpope/vim-surround',
    'tpope/vim-commentary',
    'tpope/vim-fugitive',
    'tpope/vim-sleuth',
    'tpope/vim-repeat',
    'tpope/vim-abolish',

    -- { 'kyazdani42/nvim-tree.lua', config = function() require('plugin.navigation.tree') end },
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = 'v2.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
        },
        config = function()
            require('plugin.navigation.neo-tree')
        end
    },

    'tommcdo/vim-exchange',
    'tommcdo/vim-lion',
    { 'echasnovski/mini.ai', branch = 'stable', config = function() require('mini.ai').setup() end },

    -- Better matchup '%' usage
    {
        'andymass/vim-matchup',
        config = function() vim.g.matchup_matchparen_offscreen = { method = 'status_manual' } end
    },

    {
        'phaazon/mind.nvim',
        branch = 'v2.2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('plugin.navigation.mind')
        end
    }
}

return navigation_plugins
