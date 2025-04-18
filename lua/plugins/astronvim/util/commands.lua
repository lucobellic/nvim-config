local M = {}

--- @type vim.diagnostic.Opts.VirtualText
local diagnostic_virtual_text = {
  spacing = 1,
  source = 'if_many',
  severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  prefix = '',
}

--- @type vim.diagnostic.Opts.VirtualText
local diagnostic_current_virtual_text = vim.tbl_extend('force', diagnostic_virtual_text, { current_line = true })

--- @type vim.diagnostic.Opts.VirtualLines
local diagnostic_virtual_lines = { severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR } }

--- @type vim.diagnostic.Opts.VirtualLines
local diagnostic_current_virtual_lines = vim.tbl_extend('force', diagnostic_virtual_text, { current_line = true })

function M.toggle_diagnostic_virtual_text()
  if not vim.diagnostic.config().virtual_text then
    vim.diagnostic.config({ virtual_text = diagnostic_current_virtual_text })
    vim.notify('Enabled Diagnostic Current Vitrtual Text', vim.log.levels.INFO, { title = 'Diagnostic' })
  elseif vim.diagnostic.config().virtual_text['current_line'] then
    vim.diagnostic.config({ virtual_text = diagnostic_virtual_text })
    vim.notify('Enabled Diagnostic Virtual Text', vim.log.levels.INFO, { title = 'Diagnostic' })
  else
    vim.diagnostic.config({ virtual_text = false })
    vim.notify('Disabled Diagnostic Virtual Text', vim.log.levels.INFO, { title = 'Diagnostic' })
  end
end

function M.toggle_diagnostic_virtual_lines()
  if not vim.diagnostic.config().virtual_lines then
    vim.diagnostic.config({ virtual_lines = diagnostic_current_virtual_lines })
    vim.notify('Enabled Diagnostic Current Lines', vim.log.levels.INFO, { title = 'Diagnostic' })
  elseif vim.diagnostic.config().virtual_lines['current_line'] then
    vim.diagnostic.config({ virtual_lines = diagnostic_virtual_lines })
    vim.notify('Enabled Diagnostic Lines', vim.log.levels.INFO, { title = 'Diagnostic' })
  else
    vim.diagnostic.config({ virtual_lines = false })
    vim.notify('Disabled Diagnostics Lines', vim.log.levels.WARN, { title = 'Diagnostic' })
  end
end

function M.toggle_diagnostics()
  local diagnostic_enabled = vim.diagnostic.is_enabled()
  if diagnostic_enabled then
    vim.diagnostic.enable(false)
    vim.notify('Disabled Diagnostics', vim.log.levels.WARN, { title = 'Diagnostic' })
  else
    vim.diagnostic.enable(true)
    vim.notify('Enabled Diagnostics', vim.log.levels.INFO, { title = 'Diagnostic' })
  end
end

function M.toggle_diagnostic_underline()
  if not vim.diagnostic.config().underline then
    vim.diagnostic.config({ underline = true })
    vim.notify('Enabled Diagnostics Underline', vim.log.levels.INFO, { title = 'Diagnostic' })
  else
    vim.diagnostic.config({ underline = false })
    vim.notify('Disabled Diagnostics Underline', vim.log.levels.WARN, { title = 'Diagnostic' })
  end
end

function M.repeat_change()
  if vim.g.change_text then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('cgn' .. vim.g.change_text .. '<esc>', true, false, true),
      'n',
      false
    )
  end
end

return M
