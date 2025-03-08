return {
  'ravitemer/mcphub.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  build = 'npm install -g mcp-hub@latest',
  opts = {
    port = 3000,
    config = vim.fn.expand('~/.config/nvim/.mcp/mcpservers.json'),
  },
}
