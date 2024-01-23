local diagnostic_virtual_text = {
  spacing = 1,
  source = 'if_many',
  prefix = ' ',
}

-- Diagnostic toggle
vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualText',
  function()
    vim.diagnostic.config({
      virtual_text = not vim.diagnostic.config().virtual_text and diagnostic_virtual_text or false,
    })
  end,
  { desc = 'Toggle diagnostic virtual text' }
)

vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualLines',
  function()
    vim.diagnostic.config({
      virtual_lines = not vim.diagnostic.config().virtual_lines,
    })
  end,
  { desc = 'Toggle diagnostic virtual lines' }
)
