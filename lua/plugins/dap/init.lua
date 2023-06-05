return {
  {
    'mfussenegger/nvim-dap',

    dependencies = {

      -- fancy UI for the debugger
      {
        'rcarriga/nvim-dap-ui',
        event = "VeryLazy",
        -- stylua: ignore
        keys = {
          { '<leader>du', function() require('dapui').toggle({}) end, desc = 'Dap UI' },
          { '<leader>de', function() require('dapui').eval() end,     desc = 'Eval',  mode = { 'n', 'v' } },
        },
        opts = {
          floating = {
            border = 'rounded'
          }
        },
        config = function(_, opts)
          local dap = require('dap')
          local dapui = require('dapui')
          dapui.setup(opts)

          dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open({})
          end
          dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close({})
          end
          dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close({})
          end
        end,
      },

      -- json5 support
      {
        'Joakker/lua-json5',
        build = './install.sh' -- require rust cargo to build
      },

      -- which key integration
      {
        'folke/which-key.nvim',
        opts = {
          defaults = {
            ['<leader>d'] = { name = '+debug' },
            ['<leader>da'] = { name = '+adapters' },
          },
        },
      },

      -- mason.nvim integration
      {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = 'mason.nvim',
        cmd = { 'DapInstall', 'DapUninstall' },
        opts = {
          -- Makes a best effort to setup the various debuggers with
          -- reasonable debug configurations
          automatic_setup = true,

          -- Provide additional configuration to the handlers,
          -- see mason-nvim-dap README for more information
          handlers = {},
          ensure_installed = { 'cpptools', 'python' },
        },
      },
    },

    -- stylua: ignore
    keys = {
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Breakpoint Condition' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end,                                    desc = 'Toggle Breakpoint' },
      { '<leader>dc', function() require('dap').continue() end,                                             desc = 'Continue' },
      { '<leader>dC', function() require('dap').run_to_cursor() end,                                        desc = 'Run to Cursor' },
      { '<leader>dg', function() require('dap').goto_() end,                                                desc = 'Go to line (no execute)' },
      { '<leader>di', function() require('dap').step_into() end,                                            desc = 'Step Into' },
      { '<leader>dj', function() require('dap').down() end,                                                 desc = 'Down' },
      { '<leader>dk', function() require('dap').up() end,                                                   desc = 'Up' },
      { '<leader>da', function() require('dap').run_last() end,                                             desc = 'Run Last' },
      { '<leader>do', function() require('dap').step_out() end,                                             desc = 'Step Out' },
      { '<leader>dO', function() require('dap').step_over() end,                                            desc = 'Step Over' },
      { '<leader>dp', function() require('dap').pause() end,                                                desc = 'Pause' },
      { '<leader>dr', function() require('dap').repl.toggle() end,                                          desc = 'Toggle REPL' },
      { '<leader>ds', function() require('dap').session() end,                                              desc = 'Session' },
      { '<leader>dq', function() require('dap').terminate() end,                                            desc = 'Terminate' },
      { '<leader>dx', function() require('dap.ext.vscode').load_launchjs() end,                             desc = 'Load launch.json' },
      { '<leader>dw', function() require('dap.ui.widgets').hover() end,                                     desc = 'Widgets' },
    },

    config = function()
      -- json5 support
      require('dap.ext.vscode').json_decode = require 'json5'.parse

      local dap = require('dap')
      dap.defaults.fallback.integrated_terminal = {
        command = 'zsh',
        args = { '-ci' }
      }

      -- Setup ui and icons
      local dap_icons = {
        Stopped = { ' ', 'DiagnosticWarn', 'DapStoppedLine' }, --  
        Breakpoint = { ' ', 'DiagnosticError' }, -- 󰧞  
        BreakpointCondition = { '󱗜 ', 'DiagnosticError' }, --  󰬸 󱡓 󰻂 󱗜
        BreakpointRejected = { ' ', 'DiagnosticError' }, --  󰀨 
        LogPoint = '.>',
      }

      vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

      for name, sign in pairs(dap_icons) do
        sign = type(sign) == 'table' and sign or { sign }
        vim.fn.sign_define(
          'Dap' .. name,
          { text = sign[1], texthl = sign[2] or 'DiagnosticInfo' }
        )
      end
    end
  },
  {
    'mfussenegger/nvim-dap-python',
    event = "VeryLazy",
    config = function() require('plugins.dap.python') end
  },

  -- Tests
  {
    'nvim-neotest/neotest',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'rouge8/neotest-rust',
      'nvim-neotest/neotest-plenary',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-vim-test'
    },
    config = function()
      require('plugins.dap.neotest')
    end
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
    'skywind3000/asynctasks.vim',
    dependencies = { 'skywind3000/asyncrun.vim' },
    event = 'VeryLazy',
    config = function()
      require('plugins.dap.asynctasks')
    end
  },
}
