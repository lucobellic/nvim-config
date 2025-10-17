pcall(function() vim.keymap.del('n', '<leader>n') end)
pcall(function() vim.keymap.del('n', '<leader>e') end)
pcall(function() vim.keymap.del('n', '<leader>.') end)
pcall(function() vim.keymap.del('n', 'gc') end)
vim.keymap.set('n', 'gc', '<Nop>', { noremap = true, silent = true, desc = 'comment' })
pcall(function() vim.keymap.del('n', '<leader>l') end)
pcall(function() vim.keymap.del('n', '<leader>rb') end)

if not vim.g.vscode then
  local function tab()
    -- Check for Neovim version >= 0.12
    local is_nvim_012 = vim.fn.has('nvim-0.12') == 1
    local buf = vim.api.nvim_get_current_buf()
    local nes_state = vim.b[buf].nes_state

    if is_nvim_012 then
      if vim.lsp.inline_completion.get() then
        return
      end

      if require('sidekick').nes_jump_or_apply() then
        return
      end

      if require('blink.cmp').accept() then
        return
      end

      -- fallback to space instead of tab
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Space>', true, false, true), 'n', false)
    end

    -- For Neovim < 0.12, try Copilot suggestion, Copilot NES, or Blink CMP
    local ok_copilot, copilot_suggestion = pcall(require, 'copilot.suggestion')
    if ok_copilot and copilot_suggestion.is_visible() then
      copilot_suggestion.accept()
      return
    end

    if nes_state then
      require('copilot-lsp.nes').apply_pending_nes()
      return
    end

    if require('blink.cmp').accept() then
      return
    end

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
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
