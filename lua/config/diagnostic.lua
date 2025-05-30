--- @class DiagnosticModule
--- @field diagnostic_virtual_text vim.diagnostic.Opts.VirtualText
--- @field diagnostic_current_virtual_text vim.diagnostic.Opts.VirtualText
--- @field diagnostic_virtual_lines vim.diagnostic.Opts.VirtualLines
--- @field diagnostic_current_virtual_lines vim.diagnostic.Opts.VirtualLines
local Diagnostic = {
  diagnostic_virtual_text = {
    spacing = 1,
    source = 'if_many',
    severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
    prefix = '',
    suffix = '   ',
    virt_text_pos = 'eol_right_align',
  },

  diagnostic_virtual_lines = {
    severity = { vim.diagnostic.severity.WARN, vim.diagnostic.severity.ERROR },
  },
}

--- @type vim.diagnostic.Opts.VirtualText
Diagnostic.diagnostic_current_virtual_text = vim.tbl_extend('force', Diagnostic.diagnostic_virtual_text, {
  current_line = true,
})

--- @type vim.diagnostic.Opts.VirtualLines
Diagnostic.diagnostic_current_virtual_lines = vim.tbl_extend('force', Diagnostic.diagnostic_virtual_lines, {
  current_line = true,
})

--- Helper function to send notifications
--- @private
--- @param message string The notification message
--- @param level? integer The log level (defaults to info)
function Diagnostic._notify_diagnostic(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = 'Diagnostic' })
end

--- Messages configuration for toggle functions
--- @class ToggleMessages
--- @field current string Message when enabling current line mode
--- @field normal string Message when enabling normal mode
--- @field disabled string Message when disabling feature

--- Generic toggle function for diagnostic features with three states
--- @private
--- @param config_key string The diagnostic config key to toggle
--- @param normal_config vim.diagnostic.Opts.VirtualText|vim.diagnostic.Opts.VirtualLines Normal configuration
--- @param current_config vim.diagnostic.Opts.VirtualText|vim.diagnostic.Opts.VirtualLines Current line configuration
--- @param messages ToggleMessages Messages for different states
function Diagnostic._toggle_diagnostic_feature(config_key, normal_config, current_config, messages)
  local current_value = vim.diagnostic.config()[config_key]

  if not current_value then
    vim.diagnostic.config({ [config_key] = current_config })
    Diagnostic._notify_diagnostic(messages.current, vim.log.levels.INFO)
  elseif current_value.current_line then
    vim.diagnostic.config({ [config_key] = normal_config })
    Diagnostic._notify_diagnostic(messages.normal, vim.log.levels.INFO)
  else
    vim.diagnostic.config({ [config_key] = false })
    Diagnostic._notify_diagnostic(messages.disabled, vim.log.levels.WARN)
  end
end

--- Generic toggle function for simple boolean features
--- @private
--- @param config_key string The diagnostic config key to toggle
--- @param enabled_msg string Message when feature is enabled
--- @param disabled_msg string Message when feature is disabled
function Diagnostic._toggle_boolean_feature(config_key, enabled_msg, disabled_msg)
  local current_value = vim.diagnostic.config()[config_key]
  local new_value = not current_value

  vim.diagnostic.config({ [config_key] = new_value })
  local message = new_value and enabled_msg or disabled_msg
  local level = new_value and vim.log.levels.INFO or vim.log.levels.WARN
  Diagnostic._notify_diagnostic(message, level)
end

--- Setup diagnostic user commands
function Diagnostic.setup()
  -- Diagnostic toggle commands
  vim.api.nvim_create_user_command(
    'ToggleDiagnosticVirtualText',
    function()
      Diagnostic._toggle_diagnostic_feature(
        'virtual_text',
        Diagnostic.diagnostic_virtual_text,
        Diagnostic.diagnostic_current_virtual_text,
        {
          current = 'Enabled Diagnostic Current Virtual Text',
          normal = 'Enabled Diagnostic Virtual Text',
          disabled = 'Disabled Diagnostics Virtual Text',
        }
      )
    end,
    { desc = 'Toggle Diagnostic Virtual Text' }
  )

  vim.api.nvim_create_user_command(
    'ToggleDiagnosticVirtualLines',
    function()
      Diagnostic._toggle_diagnostic_feature(
        'virtual_lines',
        Diagnostic.diagnostic_virtual_lines,
        Diagnostic.diagnostic_current_virtual_lines,
        {
          current = 'Enabled Diagnostic Current Lines',
          normal = 'Enabled Diagnostic Lines',
          disabled = 'Disabled Diagnostics Lines',
        }
      )
    end,
    { desc = 'Toggle Diagnostic Line' }
  )

  vim.api.nvim_create_user_command('ToggleDiagnostics', function()
    local diagnostic_enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not diagnostic_enabled)
    local message = diagnostic_enabled and 'Disabled Diagnostics' or 'Enabled Diagnostics'
    local level = diagnostic_enabled and vim.log.levels.WARN or vim.log.levels.INFO
    Diagnostic._notify_diagnostic(message, level)
  end, { desc = 'Toggle Diagnostics' })

  vim.api.nvim_create_user_command(
    'ToggleDiagnosticsUnderline',
    function()
      Diagnostic._toggle_boolean_feature('underline', 'Enabled Diagnostics Underline', 'Disabled Diagnostics Underline')
    end,
    { desc = 'Toggle Diagnostics Underline' }
  )
end

Diagnostic.setup()
