local signs = { Error = "•", Warn = "•", Hint = "•", Info = "•" }
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = false,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  float = { source = true, header = {} }
})

vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualText',
  function()
    vim.diagnostic.config({
      virtual_text = not vim.diagnostic.config().virtual_text
    })
  end,
  { desc = 'Toggle diagnostic virtual text' }
)

vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualLines',
  function()
    vim.diagnostic.config({
      virtual_lines = not vim.diagnostic.config().virtual_lines
    })
  end,
  { desc = 'Toggle diagnostic virtual lines' }
)

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Highlight line number instead of having icons in sign column
vim.cmd [[
  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]
