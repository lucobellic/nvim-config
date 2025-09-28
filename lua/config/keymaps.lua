pcall(function() vim.keymap.del('n', '<leader>n') end)
pcall(function() vim.keymap.del('n', '<leader>e') end)
pcall(function() vim.keymap.del('n', '<leader>.') end)
pcall(function() vim.keymap.del('n', 'gc') end)
vim.keymap.set('n', 'gc', '<Nop>', { noremap = true, silent = true, desc = 'comment' })
pcall(function() vim.keymap.del('n', '<leader>l') end)
pcall(function() vim.keymap.del('n', '<leader>rb') end)

if not vim.g.vscode then
  local function tab()
    local ok, copilot_suggestion = pcall(require, 'copilot.suggestion')
    if ok and copilot_suggestion.is_visible() then
      copilot_suggestion.accept()
    elseif vim.b[vim.api.nvim_get_current_buf()].nes_state then
      require('copilot-lsp.nes').apply_pending_nes()
    elseif not require('blink.cmp').accept() then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
    end
  end

  vim.keymap.set({ 'n', 'v' }, 'c', '<cmd>lua vim.g.change = true<cr>c', { noremap = true, desc = 'Change' })
  vim.keymap.set({ 'i', 'n' }, '<Tab>', tab, { desc = 'Next suggestion' })
  vim.keymap.set(
    { 'i', 'n' },
    '<S-Tab>',
    function() require('copilot-lsp.nes').apply_pending_nes() end,
    { desc = 'Next suggestion' }
  )
end
