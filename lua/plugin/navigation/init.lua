return {config = function(use)
    use {'junegunn/fzf', run = 'fzf#install()'}
    use {'junegunn/fzf.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'fzf.vim') end}

    use {'phaazon/hop.nvim', config = function() require('plugin.navigation.hop') end}
    use  'tpope/vim-sensible'
    use  'tpope/vim-surround'
    use  'tpope/vim-commentary'
    use  'tpope/vim-fugitive'
    use  'tpope/vim-sleuth'
    use  'tpope/vim-repeat'


    use {'kyazdani42/nvim-tree.lua', config = function() require('plugin.navigation.tree') end}

    use 'tommcdo/vim-exchange'
    use 'tommcdo/vim-lion'

    use 'kana/vim-textobj-user'      -- user defined textobj
    use 'kana/vim-textobj-line'      -- il/ib line selection
    use 'rhysd/vim-textobj-anyblock' -- ib/ab block selection

    -- Better matchup '%' usage
    use {'andymass/vim-matchup', event = 'VimEnter', config = function() vim.g.matchup_matchparen_offscreen = {method='status_manual'} end}
  end
}



