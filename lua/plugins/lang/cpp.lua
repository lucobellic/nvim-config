return {
  {
    'Civitasv/cmake-tools.nvim',
    opts = {
      cmake_executor = {
        name = 'overseer',
      },
      cmake_virtual_text_support = false,
      cmake_notifications = {
        runner = { enabled = false },
        executor = { enabled = false },
      },
    },
  },
  {
    'p00f/clangd_extensions.nvim',
    opts = {
      extensions = {
        autoSetHints = false,
      },
    },
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
          root_dir = function(fname) return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1]) end,
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
        },
      },
    },
  },
}
