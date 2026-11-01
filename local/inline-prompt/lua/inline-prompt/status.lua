---@class InlinePrompt.Status
local M = {}

local FRAMES = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local INTERVAL = 200
-- Nerd Font icons, written as escapes because they are invisible in most editors.
local IDLE = '\u{f42e}' -- nf-oct-check
local LOGO = '\u{f4be}' -- nf-oct-dependabot

local running = 0
local frame = 1
---@type uv.uv_timer_t?
local timer

local function stop_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

---Set the number of running requests. The spinner only ticks while at least one runs.
---@public
---@param count integer
function M.update(count)
  running = count

  if count == 0 then
    stop_timer()
  elseif not timer then
    frame = 1
    timer = assert(vim.uv.new_timer())
    timer:start(
      INTERVAL,
      INTERVAL,
      vim.schedule_wrap(function()
        frame = frame % #FRAMES + 1
        vim.cmd.redrawstatus()
      end)
    )
  end

  vim.cmd.redrawstatus()
end

---Text for a statusline: a spinner while requests run, then the logo and the count from two requests.
---@public
---@return string
function M.render()
  local count = running > 1 and (' ' .. running) or ''
  return (running > 0 and FRAMES[frame] or IDLE) .. ' ' .. LOGO .. count .. ' '
end

return M
