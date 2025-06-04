if vim.g.vscode then
  local vscode = require('vscode')
  vim.keymap.set(
    { 'n' },
    '<leader>db',
    function() vscode.action('editor.debug.action.toggleBreakpoint') end,
    { repeatable = true, desc = 'Toggle Breakpoint' }
  )
  vim.keymap.set(
    { 'n' },
    '<leader>dq',
    function() vscode.action('workbench.action.debug.stop') end,
    { repeatable = true, desc = 'Terminate' }
  )
  vim.keymap.set(
    { 'n' },
    '<leader>dc',
    function() vscode.action('workbench.action.debug.start') end,
    { repeatable = true, desc = 'Continue' }
  )
  vim.keymap.set(
    { 'n' },
    '<leader>dC',
    function() vscode.action('editor.debug.action.runToCursor') end,
    { repeatable = true, desc = 'Run to Cursor' }
  )
  vim.keymap.set(
    { 'n' },
    '<leader>di',
    function() vscode.action('workbench.action.debug.stepInto') end,
    { repeatable = true, desc = 'Step Into' }
  )
  vim.keymap.set(
    { 'n' },
    '<leader>do',
    function() vscode.action('workbench.action.debug.stepOut') end,
    { repeatable = true, desc = 'Step Out' }
  )
  vim.keymap.set(
    { 'n' },
    '<leader>dO',
    function() vscode.action('workbench.action.debug.stepOver') end,
    { repeatable = true, desc = 'Step Over' }
  )
end

return {
  'mfussenegger/nvim-dap',
  enabled = not (vim.g.started_by_firenvim or vim.env.KITTY_SCROLLBACK_NVIM == 'true'),
  dependencies = {
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
        local path = ''
        if vim.g.distribution == 'lazyvim' then
          path = require('mason-registry').get_package('debugpy'):get_install_path()
        else
          path = require('mason-registry')
              .get_package('debugpy')
              :get_install_handle()
              :and_then(function(p) return p:get_install_path() end)
              :or_else(vim.fn.stdpath('data') .. '/mason/packages/debugpy')
        end

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
                size = 0.5,
              },
              {
                id = 'watches',
                size = 0.5,
              },
            },
            position = 'left',
            size = 0.2,
          },
          {
            elements = {
              {
                id = 'stacks',
                size = 0.5,
              },
              {
                id = 'breakpoints',
                size = 0.5,
              },
            },
            position = 'right',
            size = 0.2,
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
    { '<leader>dq', function() require('dap').terminate() end,         repeatable = true, desc = 'Terminate' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, repeatable = true, desc = 'Toggle Breakpoint' },
    { '<leader>dc', function() require('dap').continue() end,          repeatable = true, desc = 'Continue' },
    { '<F5>',       function() require('dap').continue() end,          repeatable = true, desc = 'Continue' },
    { '<leader>dC', function() require('dap').run_to_cursor() end,     repeatable = true, desc = 'Run to Cursor' },
    { '<leader>di', function() require('dap').step_into() end,         repeatable = true, desc = 'Step Into' },
    { '<F11>',      function() require('dap').step_into() end,         repeatable = true, desc = 'Step Into' },
    { '<leader>dj', function() require('dap').down() end,              repeatable = true, desc = 'Down' },
    { '<leader>dk', function() require('dap').up() end,                repeatable = true, desc = 'Up' },
    { '<leader>do', function() require('dap').step_out() end,          repeatable = true, desc = 'Step Out' },
    { '<F12>',      function() require('dap').step_out() end,          repeatable = true, desc = 'Step Out' },
    { '<leader>dO', function() require('dap').step_over() end,         repeatable = true, desc = 'Step Over' },
    { '<F10>',      function() require('dap').step_over() end,         repeatable = true, desc = 'Step Over' },
  },
  opts = function(_, opts)
    local dap = require('dap')

    -- TODO find an adapter for cuda-gdb
    dap.adapters['cuda-gdb'] = {
      type = 'executable',
      name = 'cuda-gdb',
      command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7',
    }

    require("overseer").enable_dap()
    return vim.tbl_deep_extend('force', opts or {}, {
      defaults = {
        adapters = {
          cppdbg = {
            id = 'cppdbg',
            name = 'cpp',
            type = 'executable',
            command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7',
          },
          ['cuda-gdb'] = {
            id = 'cuda-gdb',
            name = 'cpp',
            type = 'executable',
            command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7',
          },
        },
        fallback = {
          integrated_terminal = {
            command = vim.o.shell,
            args = { '-c' },
          },
        },
      },
    })
  end,
}
