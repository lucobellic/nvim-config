--- Force terminal apps to redraw once their window size settles.
---
--- When a terminal is shown again, its window is opened then resized by layout.nvim
--- in quick bursts. Full screen apps like opencode sometimes miss the last resize
--- and leave part of the screen blank. Briefly shrinking the pty by one column then
--- restoring it makes the app repaint everything at the right size.
local M = {}

local SETTLE_DELAY_MS = 150
local RESTORE_DELAY_MS = 50

---@type table<integer, uv.uv_timer_t>
local timers = {}

---@param bufnr integer
---@return integer[]
local function visible_windows(bufnr)
  return vim.tbl_filter(
    function(win) return vim.api.nvim_win_get_buf(win) == bufnr end,
    vim.api.nvim_tabpage_list_wins(0)
  )
end

--- Neovim sizes the terminal to the smallest window showing it.
---@param bufnr integer
---@return integer? width, integer? height
local function terminal_size(bufnr)
  local width, height
  vim.iter(visible_windows(bufnr)):each(function(win)
    local info = vim.fn.getwininfo(win)[1]
    width = math.min(width or math.huge, info.width - info.textoff)
    height = math.min(height or math.huge, info.height)
  end)
  return width, height
end

---@param bufnr integer
local function nudge(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= 'terminal' then
    return
  end
  local channel = vim.bo[bufnr].channel
  local width, height = terminal_size(bufnr)
  if channel == 0 or not width or width < 2 then
    return
  end

  if not pcall(vim.fn.jobresize, channel, width - 1, height) then
    return
  end
  vim.defer_fn(function()
    -- The window may have changed meanwhile, so read the size again.
    local current_width, current_height = terminal_size(bufnr)
    pcall(vim.fn.jobresize, channel, current_width or width, current_height or height)
  end, RESTORE_DELAY_MS)
end

--- Wait for resizes to stop before refreshing, so a burst triggers a single redraw.
---@param bufnr integer
local function schedule_nudge(bufnr)
  local timer = timers[bufnr] or vim.uv.new_timer()
  timers[bufnr] = timer
  timer:stop()
  timer:start(SETTLE_DELAY_MS, 0, vim.schedule_wrap(function() nudge(bufnr) end))
end

---@param bufnr integer
local function forget(bufnr)
  local timer = timers[bufnr]
  if timer then
    timer:stop()
    timer:close()
    timers[bufnr] = nil
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('TerminalRefresh', { clear = true })

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    callback = function(args)
      if vim.bo[args.buf].buftype == 'terminal' then
        schedule_nudge(args.buf)
      end
    end,
    desc = 'Refresh terminal when shown in a window',
  })

  vim.api.nvim_create_autocmd('WinResized', {
    group = group,
    callback = function()
      vim
        .iter(vim.v.event.windows)
        :filter(vim.api.nvim_win_is_valid)
        :map(vim.api.nvim_win_get_buf)
        :filter(function(bufnr) return vim.bo[bufnr].buftype == 'terminal' end)
        :each(schedule_nudge)
    end,
    desc = 'Refresh terminal after its window is resized',
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(args) forget(args.buf) end,
    desc = 'Release terminal refresh timer',
  })
end

return M
