if vim.g.vscode then
  local vscode = require('vscode')
  vim.keymap.set('n', '<leader>w', '<C-w>', { remap = true })

  vim.keymap.set(
    'n',
    '<leader>;e',
    function() vscode.action('workbench.action.toggleSidebarVisibility') end,
    { desc = 'Toggle sidebar visibility' }
  )

  vim.keymap.set(
    'n',
    '<leader>;p',
    function() vscode.action('workbench.action.terminal.toggleTerminal') end,
    { desc = 'Toggle terminal' }
  )

  vim.keymap.set(
    'n',
    '<leader>wl',
    function() vscode.action('workbench.action.toggleAuxiliaryBar') end,
    { desc = 'Toggle right bar' }
  )

  vim.keymap.set(
    'n',
    '<leader>wh',
    function() vscode.action('workbench.action.toggleSidebarVisibility') end,
    { desc = 'Toggle left bar' }
  )

  vim.keymap.set(
    'n',
    '<leader>wj',
    function() vscode.action('workbench.action.togglePanel') end,
    { desc = 'Toggle panel' }
  )

  vim.keymap.set(
    'n',
    '<C-q>',
    function() vscode.action('workbench.action.closeActiveEditor') end,
    { desc = 'Close active editor' }
  )

  vim.keymap.set(
    'n',
    '<c-up>',
    function() vscode.action('workbench.action.increaseViewHeight') end,
    { desc = 'Increase Window Height' }
  )
  vim.keymap.set(
    'n',
    '<c-down>',
    function() vscode.action('workbench.action.decreaseViewHeight') end,
    { desc = 'Decrease Window Height' }
  )
  vim.keymap.set(
    'n',
    '<c-left>',
    function() vscode.action('workbench.action.decreaseViewWidth') end,
    { desc = 'Decrease Window Width' }
  )
  vim.keymap.set(
    'n',
    '<c-right>',
    function() vscode.action('workbench.action.increaseViewWidth') end,
    { desc = 'Increase Window Width' }
  )
end

local function get_edgy_window(direction)
  local ok, EdgyWindow = pcall(require, 'edgy.window')
  if not ok then
    return nil
  end

  local winnr = vim.fn.winnr(direction)
  local winid = vim.fn.win_getid(winnr)

  local is_win_disabled = vim.w[winid].edgy_disable
  local is_buf_disabled = vim.b[vim.api.nvim_win_get_buf(winid)].edgy_disable
  local is_edgy_valid = not is_win_disabled and not is_buf_disabled
  return is_edgy_valid and EdgyWindow.cache[winid] or nil
end

--- Creates a resize handler for edgy windows with fallback to smart-splits
---@param winnr_direction 'l'|'j'|'k'|'h' Window direction for winnr()
---@param dimension 'width'|'height' Resize dimension
---@param amount number Resize amount (positive = increase)
---@param fallback_fn string Smart-splits function name
local function create_resize_handler(winnr_direction, dimension, amount, fallback_fn)
  return function()
    local edgy_win = get_edgy_window(winnr_direction)
    if edgy_win then
      edgy_win:resize(dimension, amount)
    else
      local smart_splits_ok, smart_splits = pcall(require, 'smart-splits')
      if smart_splits_ok then
        smart_splits[fallback_fn]()
      end
    end
  end
end

return {
  'folke/which-key.nvim',
  keys = {
    {
      '<c-left>',
      create_resize_handler('l', 'width', 5, 'resize_left'),
      repeatable = true,
      desc = 'Resize left',
    },
    {
      '<c-right>',
      create_resize_handler('l', 'width', -5, 'resize_right'),
      repeatable = true,
      desc = 'Resize right',
    },
    {
      '<c-up>',
      create_resize_handler('j', 'height', 5, 'resize_up'),
      repeatable = true,
      desc = 'Resize up',
    },
    {
      '<c-down>',
      create_resize_handler('j', 'height', -5, 'resize_down'),
      repeatable = true,
      desc = 'Resize down',
    },
  },
}
