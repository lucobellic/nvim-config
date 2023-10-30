return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- json5 support
    {
      'Joakker/lua-json5',
      build = './install.sh', -- require rust cargo to build
      config = function()
        require('dap.ext.vscode').json_decode = require('json5').parse
      end,
    },
    {
      'mfussenegger/nvim-dap-python',
      config = function()
        local path = require('mason-registry').get_package('debugpy'):get_install_path()
        require('dap-python').setup(path .. '/venv/bin/python', {
          include_configs = true,
          console = 'integratedTerminal',
        })
      end,
    },
    {
      'rcarriga/nvim-dap-ui',
      keys = {
        { '<leader>de', require('dapui').eval, repeatable = true, desc = 'Step Over' },
      },
    },
  },
  keys = {
    { '<leader>dq', require('dap').terminate, repeatable = true, desc = 'Terminate' },
    { '<leader>db', require('dap').toggle_breakpoint, repeatable = true, desc = 'Toggle Breakpoint' },
    { '<leader>dc', require('dap').continue, repeatable = true, desc = 'Continue' },
    { '<leader>dC', require('dap').run_to_cursor, repeatable = true, desc = 'Run to Cursor' },
    { '<leader>di', require('dap').step_into, repeatable = true, desc = 'Step Into' },
    { '<leader>dj', require('dap').down, repeatable = true, desc = 'Down' },
    { '<leader>dk', require('dap').up, repeatable = true, desc = 'Up' },
    { '<leader>do', require('dap').step_out, repeatable = true, desc = 'Step Out' },
    { '<leader>dO', require('dap').step_over, repeatable = true, desc = 'Step Over' },
    {
      '<leader>dx',
      function()
        require('dap.ext.vscode').load_launchjs(nil, { cppdbg = { 'c', 'cpp' } })
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
          command = 'zsh',
          args = { '-c' },
        },
      },
    },
  },
}
