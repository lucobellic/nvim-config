return {
  'mfussenegger/nvim-dap',
  enabled = not (vim.g.started_by_firenvim or vim.env.KITTY_SCROLLBACK_NVIM == 'true'),
  dependencies = {
    -- json5 support
    {
      'Joakker/lua-json5',
      build = './install.sh', -- require rust cargo to build
      config = function()
        local ok, _ = pcall(require, 'json5')
        if ok then
          require('dap.ext.vscode').json_decode = require('json5').parse
        end
      end,
    },
    {
      'mfussenegger/nvim-dap-python',
      keys = {
        {
          '<leader>dPu',
          function() require('dap-python').setup('python', { include_configs = true, console = 'integratedTerminal' }) end,
          desc = 'Update Environment',
          ft = 'python',
        },
      },
      config = function()
        local path = require('mason-registry').get_package('debugpy'):get_install_path()
        require('dap-python').setup(path .. '/venv/bin/python', {
          include_configs = true,
          console = 'integratedTerminal',
        })
      end,
    },
    {
      'rcarriga/cmp-dap',
      enabled = false,
      config = function()
        local ok, cmp = pcall(require, 'cmp')
        if ok then
          cmp.setup.filetype({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, {
            sources = {
              { name = 'dap' },
            },
          })
        end
      end,
    },
    {
      'rcarriga/nvim-dap-ui',
      opts = {
        highlight_new_as_changed = true,
        commented = true,
        layouts = {
          {
            elements = {
              {
                id = 'scopes',
                size = 0.25,
              },
              {
                id = 'watches',
                size = 0.25,
              },
            },
            position = 'left',
            size = 40,
          },
          {
            elements = {
              {
                id = 'stacks',
                size = 0.25,
              },
              {
                id = 'breakpoints',
                size = 0.25,
              },
            },
            position = 'right',
            size = 40,
          },
          {
            elements = {
              {
                id = 'repl',
                size = 0.5,
              },
              {
                id = 'console',
                size = 0.5,
              },
            },
            position = 'bottom',
            size = 10,
          },
        },
      },
      keys = {
        { '<leader>de', function() require('dapui').eval() end, repeatable = true, desc = 'Step Over' },
        {
          '<leader>dw',
          function()
            local word = ''
            local mode = vim.api.nvim_get_mode().mode
            if mode == 'v' or mode == 'V' or mode == '' then
              word = table.concat(vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = mode }), '\n')
            end

            -- Fallback to word under cursor
            if word == '' then
              word = vim.fn.expand('<cword>')
            end

            vim.notify('Adding to watches: ' .. word, vim.log.levels.INFO, { title = 'DAP' })
            require('dapui').elements.watches.add(word)
          end,
          repeatable = true,
          desc = 'Add Expression To Watches',
          mode = { 'n', 'v' },
        },
      },
      config = function(_, opts)
        local dap = require('dap')
        local dapui = require('dapui')
        dapui.setup(opts)

        dap.listeners.before.event_terminated['dapui_config'] = function() end
        dap.listeners.before.event_exited['dapui_config'] = function() end
      end,
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      opts = { virt_text_pos = 'eol' },
    },
  },
  keys = {
    { '<leader>dq', function() require('dap').terminate() end, repeatable = true, desc = 'Terminate' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, repeatable = true, desc = 'Toggle Breakpoint' },
    { '<leader>dc', function() require('dap').continue() end, repeatable = true, desc = 'Continue' },
    { '<F5>', function() require('dap').continue() end, repeatable = true, desc = 'Continue' },
    { '<leader>dC', function() require('dap').run_to_cursor() end, repeatable = true, desc = 'Run to Cursor' },
    { '<leader>di', function() require('dap').step_into() end, repeatable = true, desc = 'Step Into' },
    { '<F11>', function() require('dap').step_into() end, repeatable = true, desc = 'Step Into' },
    { '<leader>dj', function() require('dap').down() end, repeatable = true, desc = 'Down' },
    { '<leader>dk', function() require('dap').up() end, repeatable = true, desc = 'Up' },
    { '<leader>do', function() require('dap').step_out() end, repeatable = true, desc = 'Step Out' },
    { '<F12>', function() require('dap').step_out() end, repeatable = true, desc = 'Step Out' },
    { '<leader>dO', function() require('dap').step_over() end, repeatable = true, desc = 'Step Over' },
    { '<F10>', function() require('dap').step_over() end, repeatable = true, desc = 'Step Over' },
    {
      '<leader>dx',
      function()
        (function() require('dap.ext.vscode').load_launchjs(nil, { cppdbg = { 'c', 'cpp' } }) end)()
      end,
      desc = 'Load launch.json',
    },
  },
  opts = {
    defaults = {
      adapters = {
        cppdbg = {
          id = 'cppdbg',
          name = 'cpp',
          type = 'executable',
          command = vim.fn.stdpath('data') .. 'mason/bin/OpenDebugAD7',
        },
      },
      fallback = {
        integrated_terminal = {
          command = vim.o.shell,
          args = { '-c' },
        },
      },
    },
  },
}
