local mode_helpers = require('plugins.ui.heirline.components.mode')

local copilot_icons = {
  Normal = '',
  Disabled = '',
  Warning = '',
  Unknown = '',
}

local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local spinner_index = 1
local function get_spinner()
  spinner_index = spinner_index % #spinner + 1
  return spinner[spinner_index]
end

local function get_copilot_icons()
  local copilot_client_ok, copilot_client = pcall(require, 'copilot.client')
  local copilot_status_ok, copilot_status = pcall(require, 'copilot.status')
  if copilot_client_ok and copilot_client.is_disabled() then
    return ' ' .. copilot_icons.Disabled
  elseif copilot_status_ok and copilot_status.data.status == 'InProgress' then
    return get_spinner() .. ' ' .. copilot_icons.Normal
  end
  local icon = copilot_status_ok and copilot_icons[copilot_status.data.status]
  return icon and (' ' .. icon) or (' ' .. copilot_icons.Warning)
end

local Copilot = {
  condition = function()
    local ok, copilot_client = pcall(require, 'copilot.client')
    return ok and not copilot_client.is_disabled() and copilot_client.buf_is_attached(vim.api.nvim_get_current_buf())
  end,
  update = {
    'User',
    pattern = { 'CopilotStatusUpdated', 'ModeChanged' },
    callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
  },
  provider = function() return get_copilot_icons() .. ' ' end,
  hl = mode_helpers.secondary_highlight,
}

local sidekick_icons = {
  Normal = '󱙺',
  Error = '󱚢',
  Warning = '󱚠',
  Inactive = '󱙻',
}

local function get_sidekick_icons()
  local sidekick_ok, status = pcall(require, 'sidekick.status')
  local status = sidekick_ok and status.get() or nil
  if status and status.busy then
    return get_spinner() .. ' ' .. sidekick_icons.Normal
  end
  local icon = status and sidekick_icons[status.kind]
  return icon and (' ' .. icon) or (' ' .. sidekick_icons.Warning)
end

local Sidekick = {
  provider = function() return get_sidekick_icons() .. ' ' end,
  hl = mode_helpers.secondary_highlight,
}

local codecompanion_processing = false
local codecompanion_timer = vim.uv.new_timer()

vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeCompanionRequest*',
  callback = function(args)
    if args.match == 'CodeCompanionRequestStarted' then
      codecompanion_processing = true
      codecompanion_timer:start(
        0,
        200,
        vim.schedule_wrap(function() vim.api.nvim_exec_autocmds('User', { pattern = 'CodeCompanionUpdated' }) end)
      )
    elseif args.match == 'CodeCompanionRequestFinished' then
      codecompanion_processing = false
      codecompanion_timer:stop()
      vim.schedule_wrap(function() vim.cmd('redrawstatus') end)
    end
  end,
})

local function get_codecompanion_icons() return codecompanion_processing and get_spinner() .. ' ' or ' ' end

local CodeCompanion = {
  provider = function() return get_codecompanion_icons() .. ' ' end,
  udpate = {
    'User',
    pattern = { 'CodeCompanionUpdated', 'ModeChanged' },
    callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
  },
  hl = mode_helpers.secondary_highlight,
}

return {
  Copilot = Copilot,
  Sidekick = Sidekick,
  CodeCompanion = CodeCompanion,
}
