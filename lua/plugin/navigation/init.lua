local navigation_plugins = {
    { 'junegunn/fzf', run = 'fzf#install()' },
    { 'junegunn/fzf.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'fzf.vim') end },

    { 'phaazon/hop.nvim', branch = 'v2', config = function() require('plugin.navigation.hop') end },
    'tpope/vim-sensible',
    'tpope/vim-surround',
    'tpope/vim-commentary',
    'tpope/vim-fugitive',
    'tpope/vim-sleuth',
    'tpope/vim-repeat',

    { 'smjonas/live-command.nvim',
        config = function()
            require("live-command").setup {
                commands = { S = { cmd = "Subvert" } }, -- must be defined before we import vim-abolish
                defaults = { inline_highlighting = false },
            }
        end
    },
    { 'tpope/vim-abolish', dependencies = { 'live-command.nvim' } },


    { 'kyazdani42/nvim-tree.lua', config = function() require('plugin.navigation.tree') end },

    'tommcdo/vim-exchange',
    'tommcdo/vim-lion',

    { 'echasnovski/mini.ai', branch = 'stable', config = function() require('mini.ai').setup() end },

    -- Better matchup '%' usage
    { 'andymass/vim-matchup',
        config = function() vim.g.matchup_matchparen_offscreen = { method = 'status_manual' } end }
}

return navigation_plugins
