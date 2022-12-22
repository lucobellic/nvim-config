return { config = function(use)

  use { 'nvim-telescope/telescope.nvim',
    requires = { 'plenary.nvim' },
    config = function() require('plugin.preview.telescope') end
  }

  use { 'Shatur/neovim-session-manager',
    requires = { 'telescope.nvim', 'plenary.nvim' },
    config = function()
      require('session_manager').setup {
        sessions_dir = vim.fn.stdpath('data') .. '/sessions', -- The directory where the session files will be saved.
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
        autoload_last_session = false, -- Automatically load last session on startup is started without arguments.
        autosave_last_session = true, -- Automatically save last session on exit.
      }
    end
  }

  use { 'stevearc/dressing.nvim', config = function() require('plugin.preview.dressing') end }

  use { 'folke/trouble.nvim',
    requires = { 'telescope.nvim' },
    config = function()
      require('trouble.providers.telescope')
      require('plugin.preview.trouble')
    end
  }

  use { 'folke/todo-comments.nvim',
    after = 'trouble.nvim',
    config = function() require('plugin.preview.todo') end
  }

  -- Either use wilder or noice
  local use_wilder = true
  local use_noice = true

  -- Enhanced wilder
  use { 'gelguy/wilder.nvim',
    config = function()
      require('plugin.preview.wilder')
    end,
    requires ='romgrk/fzy-lua-native',
    opt = true,
    cond = use_wilder
  }

  use { 'folke/noice.nvim',
    config = function()
      require('plugin.preview.noise')
    end,
    requires = {
      'MunifTanjim/nui.nvim',
    },
    opt = true,
    cond = use_noice
  }

  use { 'voldikss/vim-floaterm', config = function()
    vim.g.floaterm_autoclose = true -- Close only if the job exits normally
    -- vim.g.floaterm_borderchars = '       ' -- (top, right, bottom, left, topleft, topright, botright, botleft)
    vim.g.floaterm_borderchars = '─│─│╭╮╯╰╯'
    vim.g.floaterm_autoinsert = true
  end
  } -- Floating terminal
end
}
