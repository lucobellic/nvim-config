local editor_plugins = {
  {
    'folke/zen-mode.nvim',
    event = "VeryLazy",
    config = function()
      require('plugins.editor.zenmode')
    end
  },
  {
    'junegunn/limelight.vim',
    event = "VeryLazy",
    config = function() require('plugins.editor.limelight') end
  }, -- Highlight paragraph

  -- use term as in editor
  {
    'chomosuke/term-edit.nvim',
    event = "VeryLazy",
    config = function() require('plugins.editor.term-edit') end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    config = function()
      require('plugins.editor.indent-blankline')
    end
  },
  {
    'echasnovski/mini.indentscope',
    event = "VeryLazy",
    branch = 'stable',
    config = function()
      require('plugins.editor.indentscope')
    end
  },
  {
    'sindrets/diffview.nvim',
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('plugins.editor.diffview') end
  },
  {
    'kevinhwang91/nvim-ufo',
    event = "VeryLazy",
    dependencies = { 'kevinhwang91/promise-async' },
    config = function() require('plugins.editor.fold') end
  },
  {
    'echasnovski/mini.splitjoin',
    event = "VeryLazy",
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
    event = "VeryLazy",
    version = '*',
    config = function()
      require('mini.move').setup({
        mappings = {
          left = '',
          right = '',
          line_left = '',
          line_right = '',
        }
      })
    end
  },
  {
    'windwp/nvim-spectre',
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('plugins.editor.spectre') end
  },
  {
    'RRethy/vim-illuminate',
    event = "VeryLazy",
    config = function() require('plugins.editor.illuminate') end
  },
  {
    'andymass/vim-matchup',
    event = "VeryLazy",
    config = function()
      vim.g.matchup_matchparen_offscreen = {}
    end
  },

  -- Yank
  {
    'gbprod/yanky.nvim',
    event = "VeryLazy",
    dependencies = { 'kkharji/sqlite.lua' },
    config = function()
      require('plugins.editor.yanky')
    end
  },
  {
    -- 'Pocco81/auto-save.nvim',
    -- NOTE: Temporary replacement until [#67](https://github.com/Pocco81/auto-save.nvim/pull/67) is merged
    'zoriya/auto-save.nvim',
    event = 'VeryLazy',
    config = function()
      require("auto-save").setup {
        print_enabled = false,
        callbacks = {
          before_saving = function()
            -- Remove trailing whitespace
            local buf = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            for i, line in ipairs(lines) do
              local new_line = line:gsub("%s+$", "")
              if new_line ~= line then
                vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { new_line })
              end
            end
          end,
          enabling = nil,              -- ran when enabling auto-save
          disabling = nil,             -- ran when disabling auto-save
          before_asserting_save = nil, -- ran before checking `condition`
          after_saving = nil           -- ran after doing the actual save
        }
      }
    end,
  }
}

return editor_plugins
