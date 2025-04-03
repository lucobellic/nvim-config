if vim.g.vscode then
  local vscode = require('vscode')
  vim.notify = vscode.notify

  vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = false, silent = true })
  vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = false, silent = true })

  -- Format
  vim.keymap.set(
    'n',
    '<leader>=',
    function() vscode.action('editor.action.formatDocument') end,
    { desc = 'Format document' }
  )

  -- File Explorer
  vim.keymap.set(
    'n',
    '<leader>fe',
    function() vscode.action('workbench.explorer.fileView.focus') end,
    { desc = 'Focus file explorer' }
  )

  -- Toggle Shortcut
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

  vim.keymap.set('n', '<leader>ub', function() vscode.action('gitlens.toggleReviewMode') end, { desc = 'Line Blame' })

  -- Toggle Bars

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

  -- Windows
  vim.keymap.set('n', '<leader>w', '<C-w>', { remap = true })
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
