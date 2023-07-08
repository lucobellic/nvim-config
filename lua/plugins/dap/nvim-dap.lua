return {
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
}
