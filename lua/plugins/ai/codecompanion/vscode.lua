if vim.g.vscode then
  local vscode = require('vscode')
  local is_cursor = vscode.eval('return vscode.env.appName.includes("Cursor")')
  if is_cursor then
    vim.keymap.set(
      'n',
      '<leader>;a',
      function() vscode.action('composerMode.agent') end,
      { desc = 'Cursor Toggle Chat' }
    )
    vim.keymap.set(
      'v',
      '<leader>ai',
      function() vscode.action('aipopup.action.modal.generate') end,
      { desc = 'Cursor Inline Prompt' }
    )
    vim.keymap.set(
      'v',
      '<leader>ae',
      function() vscode.action('aichat.insertselectionintochat') end,
      { desc = 'Cursor Add Selection To Chat' }
    )
  else
    vim.keymap.set(
      'n',
      '<leader>;i',
      function() vscode.action('workbench.panel.chatEditing') end,
      { desc = 'Toggle composer view' }
    )
    vim.keymap.set(
      'n',
      '<leader>;a',
      function() vscode.action('workbench.panel.chat') end,
      { desc = 'Copilot Toggle Chat' }
    )
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>ai',
      function() vscode.action('inlineChat.start') end,
      { desc = 'Copilot Inline Prompt' }
    )
    vim.keymap.set({ 'n', 'v' }, '<leader>ae', function()
      -- vscode.action('github.copilot.chat.attachSelection')
      vscode.action('github.copilot.edits.attachSelection')
    end, { desc = 'Copilot Add Selection To Chat' })
  end
end

return {}
