-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]
vim.g.nvim_path = '$HOME/.config/nvim/'
vim.g.config_path = vim.g.nvim_path .. "config"

config_path = vim.g.config_path

return require('packer').startup(function()
  -- Packer  manage itself
  use {'wbthomason/packer.nvim', opt = false}
  use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}

  -- Completion & Languages
  use {'neoclide/coc.nvim',
    branch = 'release',
    opt = true,
    cond = function() return vim.g.lsp_provider == 'coc' end,
    run = ':CocInstall coc-explorer coc-json coc-fzf-preview coc-snippets coc-highlight coc-python coc-rls coc-toml coc-yaml coc-cmake coc-lists coc-vimlsp coc-clangd coc-pyright',
    config = function() vim.cmd('source ' .. config_path .. '/' .. 'coc.vim') end
  }
  use 'jackguo380/vim-lsp-cxx-highlight'

  use {'neovim/nvim-lspconfig', opt = true, cond = false}
  use {'glepnir/lspsaga.nvim', after = 'nvim-lspconfig'}
  use {'nvim-lua/completion-nvim', after = 'nvim-lspconfig'}

  use {'liuchengxu/vista.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'vista.vim') end} -- Outline
  use {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function() require('highlight') end
  } -- Color Syntax

  use 'rust-lang/rust.vim'
  use 'cespare/vim-toml'

  -- Navigation
  use {'phaazon/hop.nvim', config = function() require('hop-config') end}
  use  'tpope/vim-sensible'
  use  'tpope/vim-surround'
  use  'tpope/vim-commentary'
  use  'tpope/vim-fugitive'
  use  'tpope/vim-sleuth'

  -- Search and navigation
  use {'junegunn/fzf', run = 'fzf#install()'}
  use {'junegunn/fzf.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'fzf.vim') end}
  use {'liuchengxu/vim-clap', run = ':Clap install-binary'}
  use {'vn-ki/coc-clap', after = {'coc.nvim', 'vim-clap'}}

  -- Telescope
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use {'nvim-telescope/telescope.nvim', config = function() require('telescope-config') end}

  use {'fannheyward/telescope-coc.nvim',
    after = {'coc.nvim', 'telescope.nvim'},
    config = function() require('telescope').load_extension('coc') end
  }

  use {'Shatur/neovim-session-manager',
    after = 'telescope.nvim',
    config = function()
      require('telescope').load_extension('sessions')
      require('session_manager').setup {
        sessions_dir = vim.fn.stdpath('data') .. '/sessions', -- The directory where the session files will be saved.
        autoload_last_session = false, -- Automatically load last session on startup is started without arguments.
        autosave_last_session = true, -- Automatically save last session on exit.
      }
    end
  }

  -- Tasks
  use 'skywind3000/asyncrun.vim'
  use {'skywind3000/asynctasks.vim', after = 'asyncrun.vim'}
  use {'GustavoKatel/telescope-asynctasks.nvim', after = 'asynctasks.vim'}

  use {'romgrk/barbar.nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'barbar.vim') end}
  use 'tommcdo/vim-exchange'
  use 'tommcdo/vim-lion'

  use 'kana/vim-textobj-user'
  use 'rhysd/vim-textobj-anyblock'   -- 'ib/'ab selection

  -- Themes
  -- Use private personal configuration of ayu theme
  -- use {'git@gitlab.com:luco-bellic/ayu-vim.git', branch = 'personal' }
  -- use {'Luxed/ayu-vim'} -- Maintained ayu theme

  -- Icons
  use  {'kyazdani42/nvim-web-devicons', config = function() require('web-devicons') end}

  -- UI
  use {'glepnir/galaxyline.nvim', config = function() require('statusline') end}
  use {'lewis6991/gitsigns.nvim', config = function() require('gitsigns-config') end}

  use  'psliwka/vim-smoothie'    -- or Plug 'yuttie/comfortable-motion.vim'
  use {'glepnir/dashboard-nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'dashboard.vim') end}  -- Start screen
  use {'lukas-reineke/indent-blankline.nvim', config = function() require('indent') end}
  use {'folke/zen-mode.nvim', config = function() require('zenmode') end}
  use {'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'goyo.vim') end} -- Highlight paragraph
  use {'voldikss/vim-floaterm', config = function() vim.cmd('source ' .. config_path .. '/' .. '/floaterm.vim') end}  -- Floating terminal
  use  'onsails/lspkind-nvim'   -- Pictogram for neovim

  use {'folke/trouble.nvim',
    config = function()
        require('trouble-config')
        require('trouble.providers.telescope')
      end
  }
  use {'folke/todo-comments.nvim',
    after = 'trouble.nvim',
    config = function() require('todo-comments-config') end
  }

  use  'luochen1990/rainbow'  -- Color brackets

  -- Other
  use  'jceb/vim-orgmode'
  use  'xolox/vim-misc'
  use  'moll/vim-bbye'  -- Close buffer and window
  use  'honza/vim-snippets'
  use {'andymass/vim-matchup', event = 'VimEnter'} -- Better matchup '%' usage

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
