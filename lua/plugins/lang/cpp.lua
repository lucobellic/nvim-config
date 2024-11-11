return {
  {
    'p00f/clangd_extensions.nvim',
    opts = {
      extensions = {
        autoSetHints = false,
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    ft = { 'c', 'cpp' },
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'c', 'cpp' })
      end
    end,
  },
  {
    'williamboman/mason.nvim',
    ft = { 'c', 'cpp' },
    opts = function(_, opts) vim.list_extend(opts.ensure_installed, { 'clangd' }) end,
  },
  {
    'neovim/nvim-lspconfig',
    ft = { 'c', 'cpp' },
    opts = {
      servers = {
        clangd = {
          keys = {
            { '<M-o>', '<cmd>ClangdSwitchSourceHeader<cr>', desc = 'Switch Source/Header (C/C++)' },
          },
          cmd = {
            'clangd',
            '--background-index',
            '--background-index-priority=background',
            '--all-scopes-completion',
            '--pch-storage=memory',
            '--completion-style=detailed',
            '--clang-tidy',
            '--enable-config',
            '--header-insertion=iwyu',
            '--all-scopes-completion',
            '-j',
            '2',
          },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
          root_dir = function(fname) return require('lspconfig.util').find_git_ancestor(fname) end,
          capabilities = {
            offsetEncoding = { 'utf-16' },
            textDocument = {
              inlayHints = { enabled = true },
              completion = { editsNearCursor = true },
            },
          },
          settings = {
            clangd = {
              semanticHighlighting = true,
            },
          },
          on_new_config = function(new_config, new_cwd)
            local status, cmake = pcall(require, 'cmake-tools')
            if status then
              cmake.clangd_on_new_config(new_config)
            end
          end,
        },
      },
    },
  },
  {
    'mfussenegger/nvim-dap',
    optional = true,
    dependencies = {
      -- Ensure C/C++ debugger is installed
      'williamboman/mason.nvim',
      optional = true,
      opts = function(_, opts)
        if type(opts.ensure_installed) == 'table' then
          vim.list_extend(opts.ensure_installed, { 'codelldb' })
        end
      end,
    },
    opts = function()
      local dap = require('dap')
      if not dap.adapters['codelldb'] then
        require('dap').adapters['codelldb'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'codelldb',
            args = {
              '--port',
              '${port}',
            },
          },
        }
      end
      for _, lang in ipairs({ 'c', 'cpp' }) do
        dap.configurations[lang] = {
          {
            type = 'codelldb',
            request = 'launch',
            name = 'Launch file',
            program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'codelldb',
            request = 'attach',
            name = 'Attach to process',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
