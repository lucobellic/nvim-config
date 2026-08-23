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
  vim.keymap.set(
    { 'n' },
    '<leader>;d',
    function() vscode.action('workbench.view.debug') end,
    { repeatable = true, desc = 'Toggle Debug View' }
  )
end

return {}
