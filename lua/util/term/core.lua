local Term = require('util.term.term')
local config = require('util.term.config')
local ui = require('util.term.ui')
local helper = require('util.term.helper')
local event = require('nui.utils.autocmd').event

local CONSTANTS = config.CONSTANTS

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
          if helper.is_popup_visible(M) and M.popup and M.popup.winid then
            local entered_win = args.event == 'WinEnter' and vim.api.nvim_get_current_win()
              or vim.api.nvim_get_current_win()
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
  -- Validate buffer before proceeding - if invalid, remove stale terminal
  if not term:is_valid() then
    vim.notify('Terminal buffer is no longer valid: ' .. term.name, vim.log.levels.WARN)
    local term_index = term.index
    table.remove(M.terminals, term_index)
    helper.reindex_terminals(M.terminals, term_index)
    if #M.terminals > 0 then
      local next_index = math.min(term_index, #M.terminals)
      show_terminal(M.terminals[next_index])
    else
      M.hide(true)
      M.active_term = nil
    end
    return false
  end

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
  if M.popup then
    local width, height = helper.get_dimensions(term.opts)
    M.popup:update_layout({
      position = '50%',
      size = { width = width, height = height },
    })
  end

  -- Ensure the popup window is the current window before starting insert
  if helper.is_popup_visible(M) then
    vim.api.nvim_set_current_win(M.popup.winid)
    if not helper.setup_window_buffer(M.popup.winid, term.bufnr) then
      vim.notify('Failed to display terminal buffer: ' .. term.name, vim.log.levels.ERROR)
      M.popup:hide()
      return false
    end
  end

  ui.update_border(M.popup, term, #M.terminals)

  -- NUI popup sometimes has timing issues with border updates after buffer changes
  vim.defer_fn(function()
    if M.popup and M.active_term == term then
      ui.update_border(M.popup, term, #M.terminals)
    end
  end, CONSTANTS.BORDER_UPDATE_DELAY)

  if term.opts.on_open then
    term.opts.on_open(term)
  end

  if term.opts.start_insert then
    vim.cmd.startinsert()
  end
  M.active_term = term
end

--- Get or create a terminal by name
---@param name string Terminal identifier
---@param cmd? string|string[] Command to execute (required for new terminals)
---@param opts? TermOpts Terminal options
---@return Term?
function M.get_or_create(name, cmd, opts)
  local existing_term = helper.find_terminal_by_name(M.terminals, name)
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

  opts = helper.wrap_on_exit(opts, name, M.remove)

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
      if helper.is_popup_visible(M) then
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

  if helper.is_popup_visible(M) and M.active_term and M.active_term.name == name then
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
  helper.reindex_terminals(M.terminals, index)

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
      vim.defer_fn(function() M.disable_autohide = false end, CONSTANTS.AUTOHIDE_DELAY)
    end

    if unmount then
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
---@overload fun(bufnr: integer, opts?: TermOpts)
function M.new(cmd, opts)
  -- Check if cmd is an existing terminal buffer number
  if type(cmd) == 'number' and vim.api.nvim_buf_is_valid(cmd) then
    local term = helper.create_term_from_buffer(cmd, opts)
    if term then
      term.index = #M.terminals + 1
      table.insert(M.terminals, term)
      show_terminal(term)
    end
    return
  end

  -- Original behavior for cmd string
  ---@diagnostic disable-next-line: cast-local-type
  local command = cmd or vim.o.shell
  local name = helper.generate_unique_name()
  M.open(name, command, opts)
end

--- Replace current terminal with a new one without UI transition
---@param cmd? string|string[] Command to execute
---@param opts? TermOpts Terminal options
function M.replace(cmd, opts)
  if not M.active_term or not helper.is_popup_visible(M) then
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
  local name = helper.generate_unique_name()

  opts = helper.wrap_on_exit(opts, name, M.remove)

  local new_term = Term.new(name, command, opts)

  if not new_term:start() then
    vim.notify('Failed to start terminal: ' .. new_term.name, vim.log.levels.ERROR)
    return
  end

  M.terminals[old_index] = new_term
  new_term.index = old_index
  helper.reindex_terminals(M.terminals, old_index + 1)

  helper.setup_window_buffer(M.popup.winid, new_term.bufnr)

  ui.update_border(M.popup, new_term, #M.terminals)
  M.active_term = new_term

  old_term:kill()

  if new_term.opts.on_open then
    new_term.opts.on_open(new_term)
  end

  if new_term.opts.start_insert then
    vim.cmd.startinsert()
  end
end

--- Resize the popup
---@param width? number Window width (0.0-1.0 relative)
---@param height? number Window height (0.0-1.0 relative)
function M.resize(width, height)
  if not M.popup then
    return
  end

  width = width or config.get_default_width()
  height = height or config.get_default_height()

  M.popup:update_layout({
    position = '50%',
    size = { width = width, height = height },
  })

  if M.active_term then
    M.active_term.opts.width = width
    M.active_term.opts.height = height
  end
end

--- Increase terminal size by a percentage
---@param percent? number Percentage to increase (default 0.1 = 10%)
function M.increase_size(percent)
  if not helper.is_popup_visible(M) then
    return
  end

  percent = percent or CONSTANTS.DEFAULT_RESIZE_STEP
  local current_width, current_height = helper.get_dimensions(M.active_term and M.active_term.opts)

  local new_width = math.min(current_width + percent, CONSTANTS.MAX_SIZE)
  local new_height = math.min(current_height + percent, CONSTANTS.MAX_SIZE)

  M.resize(new_width, new_height)
end

--- Decrease terminal size by a percentage
---@param percent? number Percentage to decrease (default 0.1 = 10%)
function M.decrease_size(percent)
  if not helper.is_popup_visible(M) then
    return
  end

  percent = percent or CONSTANTS.DEFAULT_RESIZE_STEP
  local current_width, current_height = helper.get_dimensions(M.active_term and M.active_term.opts)

  local new_width = math.max(current_width - percent, CONSTANTS.MIN_SIZE)
  local new_height = math.max(current_height - percent, CONSTANTS.MIN_SIZE)

  M.resize(new_width, new_height)
end

--- Remove terminal from manager
---@param name string Terminal name to remove
function M.remove(name)
  local term = helper.find_terminal_by_name(M.terminals, name)
  if not term then
    return
  end

  local term_index = term.index
  local was_active = M.active_term and M.active_term.name == name
  if was_active and #M.terminals > 1 then
    local next_term_to_show = term_index < #M.terminals and M.terminals[term_index + 1] or M.terminals[term_index - 1]
    show_terminal(next_term_to_show)
  end

  if term:is_job_running() then
    term:kill()
  elseif term:is_valid() then
    pcall(vim.api.nvim_buf_delete, term.bufnr, { force = true })
  end

  table.remove(M.terminals, term_index)
  helper.reindex_terminals(M.terminals, term_index)
  if was_active and #M.terminals == 0 then
    M.hide(true)
    M.active_term = nil
  end
end

--- Get list of all terminals
---@return Term[]
function M.list() return M.terminals end

--- Detach current terminal from floating manager and open in standard window
---@return boolean success Whether the operation succeeded
function M.detach_to_window()
  if not M.active_term then
    vim.notify('No active terminal to detach', vim.log.levels.WARN)
    return false
  end

  local term = M.active_term
  if not term.bufnr or not term.index then
    vim.notify('Invalid terminal state', vim.log.levels.ERROR)
    return false
  end

  local bufnr = term.bufnr
  local term_index = term.index

  -- Remove from terminals list without killing
  table.remove(M.terminals, term_index)
  helper.reindex_terminals(M.terminals, term_index)

  -- Show next terminal if any, otherwise hide popup
  if #M.terminals > 0 then
    local next_index = math.min(term_index, #M.terminals)
    show_terminal(M.terminals[next_index])
  else
    M.hide(true)
    M.active_term = nil
  end

  -- Open buffer in a new split window
  vim.cmd('split')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, bufnr)

  -- Remove ftplugin keymaps when switching to non-floating terminal
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      local keymaps = vim.b[bufnr].term_ftplugin_keymaps
      local saved_keymaps = vim.b[bufnr].term_ftplugin_saved_keymaps

      if keymaps then
        -- First, remove all ftplugin keymaps
        for _, keymap in ipairs(keymaps) do
          local modes = type(keymap.mode) == 'table' and keymap.mode or { keymap.mode }
          for _, mode in ipairs(modes) do
            pcall(vim.keymap.del, mode, keymap.lhs, { buffer = bufnr })
          end
        end

        -- Then, restore previously saved keymaps
        if saved_keymaps then
          for _, saved in ipairs(saved_keymaps) do
            pcall(vim.keymap.set, saved.mode, saved.lhs, saved.rhs, saved.opts)
          end
        end

        -- Clear buffer variables
        vim.b[bufnr].term_ftplugin_keymaps = nil
        vim.b[bufnr].term_ftplugin_saved_keymaps = nil
      end
    end
  end)

  return true
end

--- Attach existing terminal buffer to floating manager
---@param bufnr integer Terminal buffer number
---@param opts? TermOpts Terminal options
---@return boolean success Whether the operation succeeded
function M.attach_to_floating(bufnr, opts)
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })

  if buftype ~= 'terminal' then
    vim.notify('Current buffer is not a terminal', vim.log.levels.WARN)
    return false
  end

  -- Get the current window before creating floating terminal
  local current_win = vim.api.nvim_get_current_win()

  -- Create floating terminal from existing buffer
  local term = helper.create_term_from_buffer(bufnr, opts)
  if not term then
    return false
  end

  term.index = #M.terminals + 1
  table.insert(M.terminals, term)
  show_terminal(term)

  -- Load the ftplugin for terminal
  vim.cmd('runtime! after/ftplugin/term.lua')

  -- Close/hide the original window if it's still valid and not the last one
  if vim.api.nvim_win_is_valid(current_win) then
    local wins = vim.api.nvim_list_wins()
    if #wins > 1 then
      pcall(vim.api.nvim_win_close, current_win, false)
    end
  end

  return true
end

--- Toggle terminal between floating and standard window
---@param bufnr? integer Terminal buffer number (defaults to current buffer)
---@param opts? TermOpts Terminal options for floating mode
---@return boolean success Whether the operation succeeded
function M.toggle_floating(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })

  if buftype ~= 'terminal' then
    vim.notify('Current buffer is not a terminal', vim.log.levels.WARN)
    return false
  end

  -- Check if we're in a floating terminal (managed by core)
  local is_in_floating = M.active_term and M.active_term.bufnr == bufnr

  if is_in_floating then
    return M.detach_to_window()
  else
    return M.attach_to_floating(bufnr, opts)
  end
end

return M
