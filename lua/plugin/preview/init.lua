local preview_plugins = {

  { 'folke/trouble.nvim' },
  { 'nvim-telescope/telescope.nvim',
    dependencies = { 'plenary.nvim', 'folke/trouble.nvim', 'nvim-telescope/telescope-live-grep-args.nvim' },
    config = function() require('plugin.preview.telescope') end
  },

  { 'Shatur/neovim-session-manager',
    dependencies = { 'telescope.nvim', 'plenary.nvim' },
    config = function()
      require('session_manager').setup {
        sessions_dir = vim.fn.stdpath('data') .. '/sessions', -- The directory where the session files will be saved.
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
        autoload_last_session = false, -- Automatically load last session on startup is started without arguments.
        autosave_last_session = true, -- Automatically save last session on exit.
      }
    end
  },

  { 'stevearc/dressing.nvim', config = function() require('plugin.preview.dressing') end },


  { 'folke/todo-comments.nvim',
    after = 'trouble.nvim',
    config = function() require('plugin.preview.todo') end
  },

  { 'folke/which-key.nvim', config = function() require('plugin.preview.whichkey') end },

  -- Enhanced wilder
  { 'gelguy/wilder.nvim',
    config = function()
      require('plugin.preview.wilder')
    end,
    dependencies = { 'romgrk/fzy-lua-native' },
  },

  { 'folke/noice.nvim',
    config = function()
      require('plugin.preview.noise')
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify'
    },
  },

  { 'voldikss/vim-floaterm',
    config = function()
      vim.g.floaterm_autoclose = 1 -- Close only if the job exits normally
      vim.g.floaterm_autohide = 1
      -- vim.g.floaterm_borderchars = '       ' -- (top, right, bottom, left, topleft, topright, botright, botleft)
      vim.g.floaterm_borderchars = '─│─│╭╮╯╰╯'
      vim.g.floaterm_autoinsert = true
    end
  }, -- Floating terminal

  {'akinsho/toggleterm.nvim', config = function() require('plugin.preview.toggleterm') end},
}

return preview_plugins
