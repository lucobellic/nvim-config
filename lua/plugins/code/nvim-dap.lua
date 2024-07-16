return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- json5 support
    {
      'Joakker/lua-json5',
      build = './install.sh', -- require rust cargo to build
      config = function()
        local ok, json5 = pcall('require', 'json5')
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
      'rcarriga/nvim-dap-ui',
      opts = {
        highlight_new_as_changed = true,
        commented = true,
      },
      keys = {
        { '<leader>de', require('dapui').eval, repeatable = true, desc = 'Step Over' },
        {
          '<leader>dw',
          function()
            local word = vim.fn.expand('<cword>')
            local mode = vim.api.nvim_get_mode().mode
            if mode == 'v' or mode == 'V' or mode == '\22' then
              local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
              local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))
              if start_row ~= end_row then
                end_col = #vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]
              end
              local text = vim.api.nvim_buf_get_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, {})
              word = table.concat(text, '')
            end
            require('dapui').elements.watches.add(word)
          end,
          repeatable = true,
          desc = 'Add Expression To Watches',
          mode = { 'n', 'v' },
        },
      },
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      opts = { virt_text_pos = 'eol' },
    },
  },
  keys = {
    { '<leader>id', function() require('which-key').show({ keys = '<leader>d', loop = true }) end, desc = 'Debug' },
    { '<leader>dq', require('dap').terminate, repeatable = true, desc = 'Terminate' },
    { '<leader>db', require('dap').toggle_breakpoint, repeatable = true, desc = 'Toggle Breakpoint' },
    { '<leader>dc', require('dap').continue, repeatable = true, desc = 'Continue' },
    { '<F5>', require('dap').continue, repeatable = true, desc = 'Continue' },
    { '<leader>dC', require('dap').run_to_cursor, repeatable = true, desc = 'Run to Cursor' },
    { '<leader>di', require('dap').step_into, repeatable = true, desc = 'Step Into' },
    { '<F11>', require('dap').step_into, repeatable = true, desc = 'Step Into' },
    { '<leader>dj', require('dap').down, repeatable = true, desc = 'Down' },
    { '<leader>dk', require('dap').up, repeatable = true, desc = 'Up' },
    { '<leader>do', require('dap').step_out, repeatable = true, desc = 'Step Out' },
    { '<F12>', require('dap').step_out, repeatable = true, desc = 'Step Out' },
    { '<leader>dO', require('dap').step_over, repeatable = true, desc = 'Step Over' },
    { '<F10>', require('dap').step_over, repeatable = true, desc = 'Step Over' },
    {
      '<leader>dx',
      function() require('dap.ext.vscode').load_launchjs(nil, { cppdbg = { 'c', 'cpp' } }) end,
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
