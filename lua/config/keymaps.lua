pcall(function() vim.keymap.del('n', '<leader>n') end)
pcall(function() vim.keymap.del('n', '<leader>e') end)
pcall(function() vim.keymap.del('n', '<leader>.') end)
pcall(function() vim.keymap.del('n', 'gc') end)
vim.keymap.set('n', 'gc', '<Nop>', { noremap = true, silent = true, desc = 'comment' })
pcall(function() vim.keymap.del('n', '<leader>l') end)
pcall(function() vim.keymap.del('n', '<leader>rb') end)
pcall(function() vim.keymap.del('n', '<A-j>') end)
pcall(function() vim.keymap.del('n', '<A-k>') end)
vim.keymap.set('n', '<A-j>', function() require('util.tabpages').move_buffer_to_tab('prev', true) end)
vim.keymap.set('n', '<A-k>', function() require('util.tabpages').move_buffer_to_tab('next', true) end)

-- Fix usage of localleader with which-key
vim.keymap.set('n', '<localleader>', '<cmd>lua require("which-key").show("' .. vim.g.maplocalleader .. '")<cr>')

if not vim.g.vscode then
  local function tab()
    if vim.g.suggestions == 'copilot' and vim.lsp.inline_completion.get() then
      return
    end

    if vim.g.suggestions == 'gitlab' then
      local GhostText = require('gitlab.ghost_text')
      local ns = vim.api.nvim_create_namespace('gitlab.GhostText')
      local bufnr = vim.api.nvim_get_current_buf()
      local has_suggestion = #vim.api.nvim_buf_get_extmarks(bufnr or 0, ns, 0, -1, { limit = 1 }) > 0
      if has_suggestion then
        GhostText.insert_ghost_text()
        return
      end
    end

    if require('sidekick.nes').apply() then
      return
    end

    if require('blink.cmp').accept() then
      return
    end

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
  end

  vim.keymap.set({ 'n', 'v' }, 'c', '<cmd>lua vim.g.change = true<cr>c', { noremap = true, desc = 'Change' })
  vim.keymap.set({ 'i', 'n' }, '<Tab>', tab, { desc = 'Next suggestion' })
  vim.keymap.set({ 'i', 'n' }, '<S-Tab>', function()
    if not require('sidekick.nes').apply() then
      return '<S-Tab>'
    end
  end, { desc = 'Next suggestion', expr = true })
end
