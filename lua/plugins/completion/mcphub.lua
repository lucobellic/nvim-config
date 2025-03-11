return {
  'ravitemer/mcphub.nvim',
  enabled = vim.fn.executable('npm') == 1,
  dependencies = { 'nvim-lua/plenary.nvim' },
  build = 'npm install -g mcp-hub@latest',
  opts = {
    port = 3000,
    config = vim.fn.expand('~/.config/nvim/.mcp/mcp.json'),
  },
}
