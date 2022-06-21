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

-- TODO:
--  - Find replacement for glepnir repository

require('packer').startup({function(use)
  -- Packer  manage itself
  use {'wbthomason/packer.nvim', opt = false} --, commit = '7f62848f3a92eac61ae61def5f59ddb5e2cc6823'}
  use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}

  -- Completion & Languages

  use {'neoclide/coc.nvim',
  branch = 'release',
  opt = false,
  -- Keep usage of coc-explorer as file explorer
  -- Keep proper cpp highliglith from coc-highlight and coc-clang as lsp
  run = ':CocInstall coc-explorer coc-highlight coc-clang', -- coc-json coc-fzf coc-telescope coc-snippets coc-python coc-rls coc-toml coc-yaml coc-cmake coc-lists coc-vimlsp coc-clangd coc-pyright',
  config = function()
      if vim.g.lsp_provider == 'coc' then
        vim.cmd('source ' .. config_path .. '/' .. 'coc.vim')
      else
        -- vim.fn['coc#config']('diagnostic', { enable = false })
      end
      require('colors')
      vim.cmd('source ' .. config_path .. '/' .. 'coc-explorer.vim')
    end
  }


  -- Use native nvim lsp
  use { 'neovim/nvim-lspconfig',
    requires = {{'williamboman/nvim-lsp-installer'}},
    config = function()
      require('nvim-lsp-installer').setup{}
      require('lsp')
    end
  }

  -- Completion
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  use { 'hrsh7th/cmp-cmdline' }
  use { 'hrsh7th/nvim-cmp', requires = {'onsails/lspkind.nvim'}, config = function() require('completion') end }

  use { 'stevearc/aerial.nvim' } -- LSP symbols

  -- Completion
  use { 'L3MON4D3/LuaSnip', module = 'luasnip'} -- Snippet engine
  use { 'saadparwaiz1/cmp_luasnip' }

  -- use {'liuchengxu/vista.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'vista.vim') end} -- Outline
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
  -- use {'liuchengxu/vim-clap', run = ':Clap install-binary'}
  -- use {'vn-ki/coc-clap', after = {'coc.nvim', 'vim-clap'}}

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
  use 'tommcdo/vim-exchange'
  use 'tommcdo/vim-lion'

  use 'kana/vim-textobj-user'        -- user defined textobj
  use 'kana/vim-textobj-line'        -- il/ib line selection
  use 'rhysd/vim-textobj-anyblock'   -- ib/ab block selection

  -- Themes
  -- Use private personal configuration of ayu theme
  -- use {'git@gitlab.com:luco-bellic/ayu-vim.git', branch = 'personal' }
  -- use {'Luxed/ayu-vim'} -- Maintained ayu theme

  -- Icons
  use {'kyazdani42/nvim-web-devicons', config = function() require('web-devicons') end}
  use {'onsails/lspkind.nvim'}

  -- UI
  -- TODO: change galaxyline to lualine or feline
  use {'glepnir/galaxyline.nvim', config = function() require('statusline') end}
  -- use { 'feline-nvim/feline.nvim', config = function () require('feline-config') end }
  use {'lewis6991/gitsigns.nvim',
    requires = 'plenary.nvim',
    config = function() require('gitsigns-config') end
  }

  use {'gelguy/wilder.nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'wilder.vim') end}
  use  'psliwka/vim-smoothie'    -- or Plug 'yuttie/comfortable-motion.vim'
  -- use {'glepnir/dashboard-nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'dashboard.vim') end}  -- Start screen
  use {'Neelfrost/dashboard-nvim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'dashboard.vim') end}  -- Start screen
  use {'lukas-reineke/indent-blankline.nvim', config = function() require('indent') end}
  use {'folke/zen-mode.nvim', config = function() require('zenmode') end}
  use {'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'goyo.vim') end} -- Highlight paragraph
  use {'voldikss/vim-floaterm', config = function() vim.cmd('source ' .. config_path .. '/' .. '/floaterm.vim') end}  -- Floating terminal

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
  use {'nvim-neorg/neorg',
    -- ft = 'norg', -- Load neorg only upon entering a .norg file
    after = {'nvim-treesitter', 'telescope.nvim'},
    requires = {'nvim-neorg/neorg-telescope'},
    config = function()
      require('neorg').setup {
        load = {
          ['core.defaults'] = {},
          ['core.integrations.telescope'] = {},
          ['core.norg.concealer'] = {},
          -- ['core.norg.completion'] = {},
          ['core.norg.dirman'] = {
            config = {
              workspaces = {
                work = '~/notes/work',
                home = '~/notes/home',
              }
            }
          }
        }
      }
    end
  }

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

-- Workaround to manually source the packer compiled file
local packer_compiled = vim.g.nvim_path .. '/plugin/packer_compiled.lua'
vim.cmd('luafile'  .. packer_compiled)

