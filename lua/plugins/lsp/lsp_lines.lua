return {
  'ErichDonGubler/lsp_lines.nvim',
  name = 'lsp_lines',
  event = 'VeryLazy',
  config = function()
    require("lsp_lines").setup()
  end,
}
