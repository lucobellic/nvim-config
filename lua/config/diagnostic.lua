local diagnostic_virtual_text = {
  spacing = 1,
  source = 'if_many',
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  prefix = '',
}

local diagnostic_virtual_text_line = vim.tbl_extend('force', diagnostic_virtual_text, {
  current_line = true,
})

local diagnostic_virtual_lines = {
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  highlight_whole_line = false,
  current_line = true,
  only_current_line = true,
}

-- Diagnostic toggle
vim.api.nvim_create_user_command('ToggleDiagnosticVirtualText', function()
  if not vim.diagnostic.config().virtual_text then
    vim.diagnostic.config({
      virtual_text = diagnostic_virtual_text_line,
    })
    vim.notify('Enabled Diagnostic Line', vim.log.levels.INFO, { title = 'Diagnostic' })
  elseif vim.diagnostic.config().virtual_text['current_line'] then
    vim.diagnostic.config({
      virtual_text = diagnostic_virtual_text,
    })
    vim.notify('Enabled Diagnostic Lines', vim.log.levels.INFO, { title = 'Diagnostic' })
  else
    vim.diagnostic.config({
      virtual_text = false,
    })
    vim.notify('Disabled Diagnostics Lines', vim.log.levels.WARN, { title = 'Diagnostic' })
  end
end, { desc = 'Toggle Diagnostic Virtual Text' })

vim.api.nvim_create_user_command('ToggleDiagnosticVirtualLines', function()
  local virtual_lines = vim.diagnostic.config().virtual_lines
  if not virtual_lines then
    diagnostic_virtual_lines.only_current_line = true
    vim.diagnostic.config({ virtual_lines = diagnostic_virtual_lines })
    vim.notify('Enabled Diagnostic Line', vim.log.levels.INFO, { title = 'Diagnostic' })
    vim.cmd(':e')
  elseif diagnostic_virtual_lines.only_current_line then
    diagnostic_virtual_lines.only_current_line = false
    vim.diagnostic.config({ virtual_lines = diagnostic_virtual_lines })
    vim.notify('Enabled Diagnostic Lines', vim.log.levels.INFO, { title = 'Diagnostic' })
  else
    vim.diagnostic.config({ virtual_lines = false })
    vim.notify('Disabled Diagnostic Lines', vim.log.levels.WARN, { title = 'Diagnostic' })
  end
end, { desc = 'Toggle diagnostic virtual lines' })

vim.api.nvim_create_user_command('ToggleDiagnostics', function()
  local diagnostic_enabled = vim.diagnostic.is_enabled()
  if diagnostic_enabled then
    vim.diagnostic.enable(false)
    vim.notify('Disabled Diagnostics', vim.log.levels.WARN, { title = 'Diagnostic' })
  else
    vim.diagnostic.enable(true)
    vim.notify('Enabled Diagnostics', vim.log.levels.INFO, { title = 'Diagnostic' })
  end
end, { desc = 'Toggle Diagnostics' })
