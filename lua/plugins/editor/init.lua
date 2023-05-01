local editor_plugins = {
  {
    'folke/zen-mode.nvim',
    config = function()
      require('plugins.editor.zenmode')
    end
  },
  {
    'junegunn/limelight.vim',
    config =
        function()
          vim.cmd('source ' .. vim.fn.stdpath('config') .. '/config/limelight.vim')
        end
  }, -- Highlight paragraph

  -- use term as in editor
  {
    'chomosuke/term-edit.nvim',
    config = function() require('plugins.editor.term-edit') end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require('plugins.editor.indent-blankline')
    end
  },
  {
    'echasnovski/mini.indentscope',
    branch = 'stable',
    config = function()
      require('plugins.editor.indentscope')
    end
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('plugins.editor.diffview') end
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = function() require('plugins.editor.fold') end
  },
  {
    'echasnovski/mini.splitjoin',
    config = function()
      require('mini.splitjoin').setup({
        mappings = {
          toggle = '<leader>S',
          split = '',
          join = '',
        },
      })
    end
  },
  {
    'echasnovski/mini.move',
    version = '*',
    config = function()
      require('mini.move').setup({})
    end
  },
  {
    'windwp/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('plugins.editor.spectre') end
  },
  {
    'RRethy/vim-illuminate',
    enabled = true,
    config = function() require('plugins.editor.illuminate') end
  },
  {
    "AckslD/nvim-neoclip.lua",
    requires = { 'kkharji/sqlite.lua', 'nvim-telescope/telescope.nvim' },
    after = { 'telescope.nvim' },
    config = function()
      require('plugins.editor.neoclip')
    end,
  }
}

return editor_plugins
