local diagnostic_virtual_text = {
  spacing = 1,
  source = 'if_many',
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  prefix = '',
}

local diagnostic_virtual_lines = {
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  highlight_whole_line = false
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
      virtual_lines = not vim.diagnostic.config().virtual_lines and diagnostic_virtual_lines or false,
    })
  end,
  { desc = 'Toggle diagnostic virtual lines' }
)
