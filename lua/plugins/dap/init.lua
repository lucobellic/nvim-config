return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- json5 support
      {
        'Joakker/lua-json5',
        build = './install.sh', -- require rust cargo to build
        config = function()
          require('dap.ext.vscode').json_decode = require 'json5'.parse
        end
      },
    },
    keys = {
      {
        '<leader>dq',
        function() require('dap').terminate() end,
        desc = 'Terminate'
      },
      {
        '<leader>dx',
        function()
          require('dap.ext.vscode').load_launchjs(nil, { cppdbg = { 'c', 'cpp' } })
        end,
        desc = 'Load launch.json'
      },
    },
    opts = {
      defaults = {
        fallback = {
          integrated_terminal = {
            command = 'zsh',
            args = { '-ci' }
          }
        }
      }
    },
  },
  {
    'mfussenegger/nvim-dap-python',
    event = "VeryLazy",
    config = function() require('plugins.dap.python') end
  },

  -- Tests
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/neotest-plenary',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-vim-test'
    },
    opts = {
      adapters = {
        'neotest-plenary',
        'neotest-python',
        'neotest-vim-test',
      }
    },
  },
  { 'junegunn/vader.vim', event = 'VeryLazy' },

  -- Coverage
  {
    'andythigpen/nvim-coverage',
    event = 'VeryLazy',
    dependencies = 'nvim-lua/plenary.nvim',
    -- Optional: needed for PHP when using the cobertura parser
    -- rocks = { 'lua-xmlreader' },
    config = function()
      require('coverage').setup({
        lang = {
          cpp = {
            coverage_file = './.coverage/lcov.info'
          }
        }
      })
    end,
  },

  -- Tasks
  {
    'stevearc/overseer.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>xr', ':OverseerRun<cr>',    desc = 'Overseer Run' },
      { '<leader>xi', ':OverseerInfo<cr>',   desc = 'Overseer Info' },
      { '<leader>xo', ':OverseerToggle<cr>', desc = 'Overseer Toggle' },
    },
    opts = {
      strategy = {
        'toggleterm',
        open_on_start = false,
        close_on_exit = false,
        hidden = false,
        quit_on_exit = "never",
      },
      task_list = {
        direction = 'right',
      },
      form = {
        win_opts = {
          winblend = vim.o.pumblend,
        },
      }
    },
  }
}
