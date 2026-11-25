return {
  dir = vim.fn.stdpath('config') .. '/local/lsp-ui',
  name = 'lsp-ui',
  main = 'lsp-ui',
  event = 'LspAttach',
  ---@type LspUi.Config
  opts = {},
}
