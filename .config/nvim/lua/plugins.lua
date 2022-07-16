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

require('packer').startup({function(use)
  -- Packer  manage itself
  use {'wbthomason/packer.nvim', opt = false}
  use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}

  require('plugin.lsp').config(use)
  require('plugin.completion').config(use)
  require('plugin.navigation').config(use)

  use {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function() require('highlight') end
  } -- Color Syntax

  use 'rust-lang/rust.vim'
  use 'cespare/vim-toml'

  -- Telescope
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use {'nvim-telescope/telescope.nvim',
    requires = {'plenary.nvim'},
    config = function() require('telescope-config') end
  }

  use {'fannheyward/telescope-coc.nvim',
    requires = {'telescope.nvim', 'coc.nvim'},
    opt = true,
    cond = function() return vim.g.lsp_provider == 'coc' end,
    config = function() require('telescope').load_extension('coc') end
  }

  use {'Shatur/neovim-session-manager',
    requires = {'telescope.nvim', 'plenary.nvim'},
    config = function()
      require('session_manager').setup {
        sessions_dir = vim.fn.stdpath('data') .. '/sessions', -- The directory where the session files will be saved.
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
        autoload_last_session = false, -- Automatically load last session on startup is started without arguments.
        autosave_last_session = true, -- Automatically save last session on exit.
      }
    end
  }

  -- Selector
  use {'stevearc/dressing.nvim', config = function() require('dressing-config') end}

  -- Tasks
  use 'skywind3000/asyncrun.vim'
  use {'skywind3000/asynctasks.vim', after = 'asyncrun.vim'}
  use {'GustavoKatel/telescope-asynctasks.nvim', after = 'asynctasks.vim'}

  use {'romgrk/barbar.nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'barbar.vim') end}
  -- Themes
  -- Use private personal configuration of ayu theme
  -- use {'git@gitlab.com:luco-bellic/ayu-vim.git', branch = 'personal' }
  -- use {'Luxed/ayu-vim'} -- Maintained ayu theme

  -- Icons
  use {'kyazdani42/nvim-web-devicons', config = function() require('web-devicons') end}

  -- UI
  use {'glepnir/galaxyline.nvim', config = function() require('statusline') end}
  use {'lewis6991/gitsigns.nvim',
    requires = 'plenary.nvim',
    config = function() require('gitsigns-config') end
  }

  use  'psliwka/vim-smoothie'    -- or Plug 'yuttie/comfortable-motion.vim'
  use {'glepnir/dashboard-nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'dashboard.vim') end}  -- Start screen
  use {'lukas-reineke/indent-blankline.nvim', config = function() require('indent') end}
  use {'folke/zen-mode.nvim', config = function() require('zenmode') end}
  use {'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'limelight.vim') end} -- Highlight paragraph
  use {'voldikss/vim-floaterm', config = function() vim.cmd('source ' .. config_path .. '/' .. 'floaterm.vim') end}  -- Floating terminal

  use {'folke/trouble.nvim',
    requires = {'telescope.nvim'},
    config = function()
        require('trouble.providers.telescope')
        require('trouble-config')
      end
  }
  use {'folke/todo-comments.nvim',
    after = 'trouble.nvim',
    config = function() require('todo-comments-config') end
  }

  use  'luochen1990/rainbow'  -- Color brackets

  -- Debugger
  use {'mfussenegger/nvim-dap'}
  -- use {'Shatur/neovim-cmake', config = function() require('cmake-config') end}

  -- Other
  use  'lewis6991/impatient.nvim'
  use  'xolox/vim-misc'
  use  'moll/vim-bbye'  -- Close buffer and window
  use  'honza/vim-snippets'
  use {'andymass/vim-matchup', event = 'VimEnter', config = function() vim.g.matchup_matchparen_offscreen = {method='status_manual'} end} -- Better matchup '%' usage

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end,
  config = {max_jobs=10}
})

require('colors') -- Apply coloscheme configuration

-- Workaround to manually source the packer compiled file
local packer_compiled = vim.g.nvim_path .. '/plugin/packer_compiled.lua'
vim.cmd('luafile'  .. packer_compiled)

