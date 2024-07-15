local diagnostic_virtual_text = {
  spacing = 1,
  source = 'if_many',
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  prefix = '',
}

local diagnostic_virtual_lines = {
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  highlight_whole_line = false,
  only_current_line = true,
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

vim.api.nvim_create_user_command('ToggleDiagnosticVirtualLines', function()
  local virtual_lines = vim.diagnostic.config().virtual_lines
  if not virtual_lines then
    diagnostic_virtual_lines.only_current_line = true
    vim.diagnostic.config({ virtual_lines = diagnostic_virtual_lines })
  elseif virtual_lines.only_current_line then
    diagnostic_virtual_lines.only_current_line = false
    vim.diagnostic.config({ virtual_lines = diagnostic_virtual_lines })
  else
    vim.diagnostic.config({ virtual_lines = false })
  end
end, { desc = 'Toggle diagnostic virtual lines' })
