local M = {}

-- Diagnostic configurations
local diagnostic_virtual_text = {
  spacing = 1,
  source = 'if_many',
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  prefix = '',
}

local diagnostic_current_virtual_text = vim.tbl_extend('force', diagnostic_virtual_text, {
  current_line = true,
})

local diagnostic_virtual_lines = {
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
}

local diagnostic_current_virtual_lines = vim.tbl_extend('force', diagnostic_virtual_text, {
  current_line = true,
})

function M.toggle_diagnostic_virtual_text()
  if not vim.diagnostic.config().virtual_text then
    vim.diagnostic.config({
      virtual_text = diagnostic_current_virtual_text,
    })
    vim.notify('Enabled Diagnostic Current Vitrtual Text', vim.log.levels.INFO, { title = 'Diagnostic' })
  elseif vim.diagnostic.config().virtual_text['current_line'] then
    vim.diagnostic.config({
      virtual_text = diagnostic_virtual_text,
    })
    vim.notify('Enabled Diagnostic Virtual Text', vim.log.levels.INFO, { title = 'Diagnostic' })
  else
    vim.diagnostic.config({
      virtual_text = false,
    })
    vim.notify('Disabled Diagnostic Virtual Text', vim.log.levels.INFO, { title = 'Diagnostic' })
  end
end

function M.toggle_diagnostic_virtual_lines()
  if not vim.diagnostic.config().virtual_lines then
    vim.diagnostic.config({
      virtual_lines = diagnostic_current_virtual_lines,
    })
    vim.notify('Enabled Diagnostic Current Lines', vim.log.levels.INFO, { title = 'Diagnostic' })
  elseif vim.diagnostic.config().virtual_lines['current_line'] then
    vim.diagnostic.config({
      virtual_lines = diagnostic_virtual_lines,
    })
    vim.notify('Enabled Diagnostic Lines', vim.log.levels.INFO, { title = 'Diagnostic' })
  else
    vim.diagnostic.config({
      virtual_lines = false,
    })
    vim.notify('Disabled Diagnostics Lines', vim.log.levels.WARN, { title = 'Diagnostic' })
  end
end

function M.toggle_diagnostic()
  local diagnostic_enabled = vim.diagnostic.is_enabled()
  if diagnostic_enabled then
    vim.diagnostic.enable(false)
    vim.notify('Disabled Diagnostics', vim.log.levels.WARN, { title = 'Diagnostic' })
  else
    vim.diagnostic.enable(true)
    vim.notify('Enabled Diagnostics', vim.log.levels.INFO, { title = 'Diagnostic' })
  end
end

function M.repeat_change()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('cgn' .. vim.g.change_text .. '<esc>', true, false, true),
    'n',
    false
  )
end

return M
