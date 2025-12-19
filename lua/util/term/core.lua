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
  local existing_term = vim.iter(M.terminals):filter(function(t) return t.name == name end):next()
  if existing_term then
    if existing_term:is_job_running() and existing_term:is_valid() then
      return existing_term
    end
    M.remove(name)
  end

  if not cmd then
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

  local user_on_exit = opts.on_exit
  opts.on_exit = function(term, code)
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
  if not name then
    if M.active_term then
      if is_popup_visible() then
        M.hide()
        return
      end

      M.open(M.active_term.name, cmd, opts)
      return
    else
      name = 'Terminal'
      cmd = cmd or vim.o.shell
    end
  end

  if is_popup_visible() and M.active_term and M.active_term.name == name then
    M.hide()
    return
  end

  M.open(name, cmd, opts)
end

--- Open terminal (creates if doesn't exist)
---@param name? string Terminal name (defaults to 'default')
---@param cmd? string|string[] Command to execute
---@param opts? TermOpts Terminal options
function M.open(name, cmd, opts)
  name = name or 'default'

  local term = M.get_or_create(name, cmd, opts)
  if term then
    show_terminal(term)
  end
end

--- Close active terminal (kills job and removes from list)
function M.close()
  if not M.active_term then
    return
  end

  local index = M.active_term.index
  M.active_term:kill()
  table.remove(M.terminals, index)
  reindex_terminals(index)

  -- Show remaining terminal if any or hide
  if #M.terminals > 0 then
    local next_index = math.min(index, #M.terminals)
    show_terminal(M.terminals[next_index])
  else
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
  local name = 'Terminal ' .. tostring(vim.loop.hrtime())
  M.open(name, command, opts)
end

--- Replace current terminal with a new one without UI transition
---@param cmd? string|string[] Command to execute
---@param opts? TermOpts Terminal options
function M.replace(cmd, opts)
  if not M.active_term or not is_popup_visible() then
    M.new(cmd, opts)
    return
  end

  ---@type Term
  local old_term = M.active_term
  local old_index = old_term.index

  opts = vim.tbl_deep_extend('force', config.get().defaults, opts or {})
  opts.width = old_term.opts.width
  opts.height = old_term.opts.height

  local command = cmd or vim.o.shell
  local name = 'Terminal ' .. tostring(vim.loop.hrtime())

  local user_on_exit = opts.on_exit
  opts.on_exit = function(term, code)
    if user_on_exit then
      user_on_exit(term, code)
    end
    if code == 0 then
      vim.schedule(function() M.remove(name) end)
    end
  end

  local new_term = Term.new(name, command, opts)

  if not new_term:start() then
    vim.notify('Failed to start terminal: ' .. new_term.name, vim.log.levels.ERROR)
    return
  end

  M.terminals[old_index] = new_term
  new_term.index = old_index
  reindex_terminals(old_index + 1)

  vim.api.nvim_win_set_buf(M.popup.winid, new_term.bufnr)
  vim.api.nvim_set_option_value('sidescrolloff', 0, { win = M.popup.winid })

  ui.update_border(M.popup, new_term, #M.terminals)
  M.active_term = new_term

  old_term:kill()

  if new_term.opts.on_open then
    new_term.opts.on_open(new_term)
  end

  if new_term.opts.start_insert then
    vim.cmd('startinsert')
  end
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
  local term = vim.iter(M.terminals):filter(function(t) return t.name == name end):next()
  if not term then
    return
  end

  local term_index = term.index
  local was_active = M.active_term and M.active_term.name == name
  if was_active and #M.terminals > 1 then
    next_term_to_show = term_index < #M.terminals and M.terminals[term_index + 1] or M.terminals[term_index - 1]
    show_terminal(next_term_to_show)
  end

  if term:is_job_running() then
    term:kill()
  elseif term:is_valid() then
    pcall(vim.api.nvim_buf_delete, term.bufnr, { force = true })
  end

  table.remove(M.terminals, term_index)
  reindex_terminals(term_index)
  if was_active and #M.terminals == 0 then
    M.hide(true)
    M.active_term = nil
  end
end

--- Get list of all terminals
---@return Term[]
function M.list() return M.terminals end

return M
