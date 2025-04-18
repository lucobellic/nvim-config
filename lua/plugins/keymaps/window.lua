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

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<c-left>',
      function()
        local ok, EdgyWindow = pcall(require, 'edgy.window')
        local right_edgy = ok and EdgyWindow.cache[vim.fn.win_getid(vim.fn.winnr('l'))] or nil
        if right_edgy then
          right_edgy:resize('width', 5)
        else
          local smart_splits_ok, smart_splits = pcall(require, 'smart-splits')
          if smart_splits_ok then
            smart_splits.resize_left()
          end
        end
      end,
      repeatable = true,
      desc = 'Resize left',
    },
    {

      '<c-right>',
      function()
        local ok, EdgyWindow = pcall(require, 'edgy.window')
        local right_edgy = ok and EdgyWindow.cache[vim.fn.win_getid(vim.fn.winnr('l'))] or nil
        if right_edgy then
          right_edgy:resize('width', -5)
        else
          local smart_splits_ok, smart_splits = pcall(require, 'smart-splits')
          if smart_splits_ok then
            smart_splits.resize_right()
          end
        end
      end,
      repeatable = true,
      desc = 'Resize right',
    },
    {

      '<c-up>',
      function()
        local ok, EdgyWindow = pcall(require, 'edgy.window')
        local down_edgy = ok and EdgyWindow.cache[vim.fn.win_getid(vim.fn.winnr('j'))] or nil
        if down_edgy then
          down_edgy:resize('height', 5)
        else
          local smart_splits_ok, smart_splits = pcall(require, 'smart-splits')
          if smart_splits_ok then
            smart_splits.resize_up()
          end
        end
      end,
      repeatable = true,
      desc = 'Resize up',
    },
    {

      '<c-down>',
      function()
        local ok, EdgyWindow = pcall(require, 'edgy.window')
        local down_edgy = ok and EdgyWindow.cache[vim.fn.win_getid(vim.fn.winnr('j'))] or nil
        if down_edgy then
          down_edgy:resize('height', -5)
        else
          local smart_splits_ok, smart_splits = pcall(require, 'smart-splits')
          if smart_splits_ok then
            smart_splits.resize_down()
          end
        end
      end,
      repeatable = true,
      desc = 'Resize down',
    },
  },
}
