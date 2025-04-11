return {
  {
    'ravitemer/mcphub.nvim',
    enabled = vim.fn.executable('npm') == 1,
    dependencies = { 'nvim-lua/plenary.nvim' },
    build = 'npm install -g mcp-hub@latest',
    cmd = { 'MCPHub' },
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
      strategies = {
        chat = {
          tools = {
            mcp = {
              callback = function() return require('mcphub.extensions.codecompanion') end,
              description = 'Call tools and resources from the MCP Servers',
            },
          },
        },
      },
    },
  },
}
