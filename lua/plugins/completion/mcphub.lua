return {
  {
    'ravitemer/mcphub.nvim',
    enabled = vim.fn.executable('npm') == 1,
    dependencies = { 'nvim-lua/plenary.nvim' },
    build = 'npm install -g mcp-hub@latest',
    cmd = { 'MCPHub' },
    keys = {
      { '<leader>ah', '<cmd>MCPHub<cr>', mode = { 'n' }, desc = 'Toggle MCPHub' },
    },
    opts = {
      port = 3000,
      config = vim.fn.expand('~/.config/nvim/.mcp/mcp.json'),
      extensions = {
        codecompanion = {
          show_result_in_chat = true,
          make_vars = true,
          make_slash_commands = true,
        },
      },
      ui = {
        window = {
          border = vim.g.winborder,
        },
        wo = {
          winblend = vim.o.winblend,
          winhl = 'MCPHubMuted:Normal',
        },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    opts = {
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
      },
    },
  },
}
