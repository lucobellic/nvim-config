local Term = require('util.term.term')
local config = require('util.term.config')
local ui = require('util.term.ui')
local event = require('nui.utils.autocmd').event

---@class TermCore
---@field active_term Term? Active terminal instance
---@field popup NuiPopup? Popup window instance
---@field terminals Term[] List of terminal instances
---@field private disable_autohide boolean Temporary flag to disable auto-hide
local M = {
  active_term = nil,
  popup = nil,
  terminals = {},
  disable_autohide = false,
}

--- Check if popup is currently visible and valid
---@return boolean
local function is_popup_visible()
  return M.popup ~= nil and M.popup.winid ~= nil and vim.api.nvim_win_is_valid(M.popup.winid)
end

--- Get current width and height from active terminal or config defaults
---@return number width, number height
local function get_current_dimensions()
  local cfg = config.get()
  local width = (M.active_term and M.active_term.opts.width) or cfg.defaults.width or 0.6
  local height = (M.active_term and M.active_term.opts.height) or cfg.defaults.height or 0.6
  return width, height
end

--- Reindex terminals starting from a given index
---@param start_index number Starting index for reindexing
local function reindex_terminals(start_index)
  for i = start_index, #M.terminals do
    M.terminals[i].index = i
  end
end

local function ensure_popup()
  if M.popup == nil then
    M.popup = ui.create_popup()

    -- Setup auto-hide when focus moves to another window
    -- Use WinEnter on any window to detect clicks/navigation away from popup
    local augroup = vim.api.nvim_create_augroup('TermPopupAutoHide', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
      group = augroup,
      callback = function(args)
        vim.schedule(function()
          -- Skip auto-hide if temporarily disabled (e.g., during editor-wrapper workflow)
          if M.disable_autohide then
            return
          end

          -- Only hide if popup is still valid and we entered a different window
          if is_popup_visible() and M.popup.winid then
            local entered_win = args.win or vim.api.nvim_get_current_win()
            if entered_win ~= M.popup.winid then
              M.hide()
            end
          end
        end)
      end,
    })

    -- Also handle when popup window is closed externally
    M.popup:on(event.WinClosed, function()
      vim.schedule(function()
        if M.popup then
          M.popup = nil
          M.active_term = nil
        end
      end)
    end)
  end
end

--- Show terminal in the popup
---@param term Term
local function show_terminal(term)
  ensure_popup()

  if not term:is_job_running() then
    if not term:start() then
      vim.notify('Failed to start terminal: ' .. term.name, vim.log.levels.ERROR)
      return false
    end
  end

  -- Show popup (mount if not mounted, otherwise just show)
  if M.popup then
    M.popup:show()
  end

  -- Resize popup to match terminal's dimensions
  if M.popup and term.opts then
    local cfg = config.get()
    local width = term.opts.width or cfg.defaults.width or 0.6
    local height = term.opts.height or cfg.defaults.height or 0.6

    M.popup:update_layout({
      position = '50%',
      size = {
        width = width,
        height = height,
      },
    })
  end

  -- Ensure the popup window is the current window before starting insert
  if is_popup_visible() then
    vim.api.nvim_set_current_win(M.popup.winid)
    vim.api.nvim_win_set_buf(M.popup.winid, term.bufnr)

    -- Force set window option for horizontal scrolling (sidescrolloff is window-local)
    vim.api.nvim_set_option_value('sidescrolloff', 0, { win = M.popup.winid })
  end

  ui.update_border(M.popup, term, #M.terminals)

  -- Schedule a second border update to ensure titles are refreshed after any timing issues
  vim.defer_fn(function()
    if M.popup and M.active_term == term then
      ui.update_border(M.popup, term, #M.terminals)
    end
  end, 200)

  if term.opts.on_open then
    term.opts.on_open(term)
  end

  -- Only start insert mode if explicitly enabled (default: false to preserve cursor position)
  if term.opts.start_insert then
    vim.cmd('startinsert')
  end
  M.active_term = term
end

--- Get or create a terminal by name
---@param name string Terminal identifier
---@param cmd? string|string[] Command to execute (required for new terminals)
---@param opts? TermOpts Terminal options
---@return Term?
function M.get_or_create(name, cmd, opts)
  -- Find existing terminal
  for _, term in ipairs(M.terminals) do
    if term.name == name then
      -- If terminal exists but job is not running, remove it so we create a new one
      if not term:is_job_running() and not term:is_valid() then
        M.remove(name)
        break
      end
      return term
    end
  end

  -- Create new terminal
  if not cmd then
    -- Check if it's a named terminal in config
    local named = config.get().terminals[name]
    if named then
      cmd = named.cmd
      opts = vim.tbl_deep_extend('force', config.get().defaults, named.opts or {}, opts or {})
    else
      vim.notify('Terminal "' .. name .. '" not found and no command provided', vim.log.levels.ERROR)
      return nil
    end
  else
    opts = vim.tbl_deep_extend('force', config.get().defaults, opts or {})
  end

  -- Wrap on_exit to handle cleanup
  local user_on_exit = opts.on_exit
  opts.on_exit = function(term, code)
    -- Call user callback first
    if user_on_exit then
      user_on_exit(term, code)
    end

    -- If terminal exited normally (user typed exit), remove it from manager
    -- This allows creating a fresh terminal next time
    if code == 0 then
      vim.schedule(function() M.remove(name) end)
    end
  end

  local term = Term.new(name, cmd, opts)
  term.index = #M.terminals + 1
  table.insert(M.terminals, term)

  return term
end

--- Toggle terminal visibility (creates if doesn't exist)
---@param name? string Terminal name (defaults to auto-numbered)
---@param cmd? string|string[] Command to execute
---@param opts? TermOpts Terminal options
function M.toggle(name, cmd, opts)
  -- If no name provided, use auto-numbered terminal
  if not name then
    -- If we have an active terminal, toggle it
    if M.active_term then
      if is_popup_visible() then
        M.hide()
        return
      else
        -- Reopen the last active terminal
        M.open(M.active_term.name, cmd, opts)
        return
      end
    else
      -- No active terminal, create Terminal
      name = 'Terminal'
      cmd = cmd or vim.o.shell
    end
  end

  -- If popup is visible with the same terminal, hide it
  if is_popup_visible() and M.active_term and M.active_term.name == name then
    M.hide()
    return
  end

  -- Otherwise, open the terminal
  M.open(name, cmd, opts)
end

--- Open terminal (creates if doesn't exist)
---@param name? string Terminal name (defaults to 'default')
---@param cmd? string|string[] Command to execute
---@param opts? TermOpts Terminal options
function M.open(name, cmd, opts)
  name = name or 'default'

  local term = M.get_or_create(name, cmd, opts)
  if not term then
    return
  end

  show_terminal(term)
end

--- Close active terminal (kills job and removes from list)
function M.close()
  if not M.active_term then
    return
  end

  local term = M.active_term
  if not term then
    return
  end

  local index = term.index

  -- Kill terminal
  term:kill()

  -- Remove from list
  table.remove(M.terminals, index)

  -- Update indices
  reindex_terminals(index)

  -- If there are remaining terminals, show the previous one
  if #M.terminals > 0 then
    local next_index = math.min(index, #M.terminals)
    show_terminal(M.terminals[next_index])
  else
    -- No terminals left, hide layout
    M.hide()
  end
end

--- Hide terminal popup (keeps terminals alive)
---@param unmount? boolean Whether to unmount the popup completely
---@param skip_autohide_disable? boolean Skip disabling auto-hide (for external calls)
function M.hide(unmount, skip_autohide_disable)
  if M.popup then
    -- Temporarily disable auto-hide to prevent re-triggering during hide operation
    -- This is crucial for editor-wrapper workflow
    if not skip_autohide_disable then
      M.disable_autohide = true
      vim.defer_fn(function() M.disable_autohide = false end, 100) -- Re-enable after 100ms
    end

    if unmount then
      -- Clean up autocmd group before unmounting
      pcall(vim.api.nvim_del_augroup_by_name, 'TermPopupAutoHide')
      M.popup:unmount()
      M.popup = nil
    else
      M.popup:hide()
    end
  end
end

--- Switch to next terminal
function M.next()
  if #M.terminals == 0 then
    return
  end

  local current_index = M.active_term and M.active_term.index or 0
  local next_index = (current_index % #M.terminals) + 1
  show_terminal(M.terminals[next_index])
end

--- Switch to previous terminal
function M.prev()
  if #M.terminals == 0 then
    return
  end

  local current_index = M.active_term and M.active_term.index or 2
  local prev_index = ((current_index - 2) % #M.terminals) + 1
  show_terminal(M.terminals[prev_index])
end

--- Create a new terminal with auto-incremented name
---@param cmd? string|string[] Command to execute
---@param opts? TermOpts Terminal options
function M.new(cmd, opts)
  local command = cmd or vim.o.shell
  local name = 'Terminal ' .. #M.terminals + 1
  M.open(name, command, opts)
end

--- Resize the popup
---@param width? number Window width (0.0-1.0 relative)
---@param height? number Window height (0.0-1.0 relative)
function M.resize(width, height)
  if not M.popup then
    return
  end

  local cfg = config.get()
  width = width or cfg.defaults.width or 0.6
  height = height or cfg.defaults.height or 0.6

  -- Update popup layout with relative values
  M.popup:update_layout({
    position = '50%',
    size = {
      width = width,
      height = height,
    },
  })

  -- Update active terminal's stored dimensions
  if M.active_term then
    M.active_term.opts.width = width
    M.active_term.opts.height = height
  end
end

--- Increase terminal size by a percentage
---@param percent? number Percentage to increase (default 0.1 = 10%)
function M.increase_size(percent)
  if not is_popup_visible() then
    return
  end

  percent = percent or 0.1
  local current_width, current_height = get_current_dimensions()

  -- Increase by percentage, cap at 1.0 for relative sizes
  local new_width = math.min(current_width + percent, 1.0)
  local new_height = math.min(current_height + percent, 1.0)

  M.resize(new_width, new_height)
end

--- Decrease terminal size by a percentage
---@param percent? number Percentage to decrease (default 0.1 = 10%)
function M.decrease_size(percent)
  if not is_popup_visible() then
    return
  end

  percent = percent or 0.1
  local current_width, current_height = get_current_dimensions()

  -- Decrease by percentage, keep minimum of 0.3 (30%)
  local new_width = math.max(current_width - percent, 0.3)
  local new_height = math.max(current_height - percent, 0.3)

  M.resize(new_width, new_height)
end

--- Remove terminal from manager
---@param name string Terminal name to remove
function M.remove(name)
  for i, term in ipairs(M.terminals) do
    if term.name == name then
      local was_active = M.active_term and M.active_term.name == name
      local successor = nil

      -- If this is the active terminal and there are others, pick successor and show it FIRST
      if was_active and #M.terminals > 1 then
        -- Choose successor: prefer next terminal, otherwise previous
        if i < #M.terminals then
          successor = M.terminals[i + 1]
        else
          successor = M.terminals[i - 1]
        end
        -- Show successor before we delete the current buffer
        show_terminal(successor)
      end

      -- Now kill and delete the buffer for the terminal being removed
      if term:is_job_running() then
        term:kill()
      elseif term:is_valid() then
        -- If job not running but buffer still valid, delete it
        pcall(vim.api.nvim_buf_delete, term.bufnr, { force = true })
      end

      -- Remove from list
      table.remove(M.terminals, i)

      -- Reindex remaining terminals
      reindex_terminals(i)

      -- If was active and no terminals left, hide popup
      if was_active and #M.terminals == 0 then
        M.hide(true) -- unmount = true
        M.active_term = nil
      end

      return true
    end
  end
  return false
end

--- Get list of all terminals
---@return Term[]
function M.list() return M.terminals end

return M
