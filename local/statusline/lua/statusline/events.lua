local theme = require('statusline.theme')

---@class User.Statusline.Events
local M = {}

local frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local frame = 1
local requests = 0
local redraw_pending = false
---@type uv.uv_timer_t?
local timer

---@public
function M.redraw()
  if redraw_pending then
    return
  end
  redraw_pending = true
  vim.schedule(function()
    redraw_pending = false
    vim.cmd.redrawstatus()
  end)
end

---@public
---@return string
function M.codecompanion() return (requests > 0 and frames[frame] or '') .. '  ' end

local function close_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

---@param event vim.api.keyset.create_autocmd.callback_args
local function request_changed(event)
  if event.match == 'CodeCompanionRequestStarted' then
    requests = requests + 1
    if not timer then
      frame = 1
      timer = assert(vim.uv.new_timer())
      timer:start(
        200,
        200,
        vim.schedule_wrap(function()
          frame = frame % #frames + 1
          M.redraw()
        end)
      )
    end
  else
    requests = math.max(0, requests - 1)
    if requests == 0 then
      close_timer()
    end
  end
  M.redraw()
end

---@public
function M.setup()
  close_timer()
  requests = 0
  local group = vim.api.nvim_create_augroup('UserStatusline', { clear = true })
  theme.refresh()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      theme.refresh()
      vim.schedule(theme.refresh_tasks)
      M.redraw()
    end,
  })
  vim.api.nvim_create_autocmd({ 'ModeChanged', 'RecordingEnter', 'RecordingLeave' }, {
    group = group,
    callback = M.redraw,
  })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = { 'LspProgressStatusUpdated', 'DapProgressUpdate', 'GitSignsUpdate', 'LazyCheck', 'LazyUpdate' },
    callback = M.redraw,
  })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'OverseerListUpdate',
    callback = function()
      theme.refresh_tasks()
      M.redraw()
    end,
  })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = { 'CodeCompanionRequestStarted', 'CodeCompanionRequestFinished' },
    callback = request_changed,
  })
  vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = close_timer })
end

return M
